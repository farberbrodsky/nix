# -*- coding: utf-8 -*-
# gitstatus.sh -- git repo status for prompt use
# Sourced by bashprompt.sh. Defines _gitstatus() which populates
# the global array _GIT_STATUS_FIELDS with 11 fields:
#   [0] branch+state  [1] remote  [2] remote_url  [3] upstream
#   [4] staged  [5] conflicts  [6] changed  [7] untracked
#   [8] stashed  [9] clean  [10] detached_head

# Helper for reading rebase progress files safely
__git_prompt_read() {
    local f="${1}"
    shift
    [[ -r "${f}" ]] && read -r "${@}" <"${f}"
}

_gitstatus() {
    _GIT_STATUS_FIELDS=()
    local _ignore_submodules
    if [[ "${__GIT_PROMPT_IGNORE_SUBMODULES:-0}" == "1" ]]; then
        _ignore_submodules="--ignore-submodules"
    else
        _ignore_submodules=""
    fi

    local remote_url='.'
    if [[ "${__GIT_PROMPT_WITH_USERNAME_AND_REPO:-0}" == "1" ]]; then
        remote_url=$(git config --get remote.origin.url | sed 's|^.*//||; s/.*@//; s/[^:/]\+[:/]//; s/.git$//')
    fi

    local gitstatus
    gitstatus=$( LC_ALL=C git --no-optional-locks status ${_ignore_submodules} --untracked-files="${__GIT_PROMPT_SHOW_UNTRACKED_FILES:-normal}" --porcelain --branch )

    # if the status is fatal, bail out
    [[ $? -ne 0 ]] && return 0

    local git_dir
    git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    [[ -z "${git_dir:+x}" ]] && return 0

    local state="" step="" total=""
    if [[ -d "${git_dir}/rebase-merge" ]]; then
        __git_prompt_read "${git_dir}/rebase-merge/msgnum" step
        __git_prompt_read "${git_dir}/rebase-merge/end" total
        if [[ -f "${git_dir}/rebase-merge/interactive" ]]; then
            state="|REBASE-i"
        else
            state="|REBASE-m"
        fi
    else
        if [[ -d "${git_dir}/rebase-apply" ]]; then
            __git_prompt_read "${git_dir}/rebase-apply/next" step
            __git_prompt_read "${git_dir}/rebase-apply/last" total
            if [[ -f "${git_dir}/rebase-apply/rebasing" ]]; then
                state="|REBASE"
            elif [[ -f "${git_dir}/rebase-apply/applying" ]]; then
                state="|AM"
            else
                state="|AM/REBASE"
            fi
        elif [[ -f "${git_dir}/MERGE_HEAD" ]]; then
            state="|MERGING"
        elif [[ -f "${git_dir}/CHERRY_PICK_HEAD" ]]; then
            state="|CHERRY-PICKING"
        elif [[ -f "${git_dir}/REVERT_HEAD" ]]; then
            state="|REVERTING"
        elif [[ -f "${git_dir}/BISECT_LOG" ]]; then
            state="|BISECTING"
        fi
    fi

    if [[ -n "${step}" ]] && [[ -n "${total}" ]]; then
        state="${state} ${step}/${total}"
    fi

    local num_staged=0 num_changed=0 num_conflicts=0 num_untracked=0
    local branch_line=""
    while IFS='' read -r line || [[ -n "${line}" ]]; do
        local status="${line:0:2}"
        while [[ -n ${status} ]]; do
            case "${status}" in
                \#\#) branch_line="${line/\.\.\./^}"; break ;;
                \?\?) ((num_untracked++)); break ;;
                U?)   ((num_conflicts++)); break ;;
                ?U)   ((num_conflicts++)); break ;;
                DD)   ((num_conflicts++)); break ;;
                AA)   ((num_conflicts++)); break ;;
                ?M)   ((num_changed++)) ;;
                ?\ )  ;;
                U)    ((num_conflicts++)) ;;
                \ )   ;;
                *)    ((num_staged++)) ;;
            esac
            status="${status:0:(${#status}-1)}"
        done
    done <<< "${gitstatus}"

    local num_stashed=0
    if [[ "${__GIT_PROMPT_IGNORE_STASH:-0}" != "1" ]]; then
        local stash_file="${git_dir}/logs/refs/stash"
        if [[ -e "${stash_file}" ]]; then
            while IFS='' read -r wcline || [[ -n "${wcline}" ]]; do
                ((num_stashed++))
            done < "${stash_file}"
        fi
    fi

    local clean=0
    if (( num_changed == 0 && num_staged == 0 && num_untracked == 0 && num_stashed == 0 && num_conflicts == 0 )); then
        clean=1
    fi

    local branch="" remote="" upstream="" detached_head=0
    IFS="^" read -ra branch_fields <<< "${branch_line/\#\# }"
    branch="${branch_fields[0]}"

    if [[ "${branch}" == *"Initial commit on"* ]]; then
        IFS=" " read -ra fields <<< "${branch}"
        branch="${fields[3]}"
        remote="_NO_REMOTE_TRACKING_"
        remote_url='.'
    elif [[ "${branch}" == *"No commits yet on"* ]]; then
        IFS=" " read -ra fields <<< "${branch}"
        branch="${fields[4]}"
        remote="_NO_REMOTE_TRACKING_"
        remote_url='.'
    elif [[ "${branch}" == *"no branch"* ]]; then
        local tag
        tag=$( git describe --tags --exact-match 2>/dev/null )
        if [[ -n "${tag}" ]]; then
            branch="_PRETAG_${tag}"
            detached_head=1
        else
            branch="_PREHASH_$( git rev-parse --short HEAD 2>/dev/null )"
            detached_head=1
        fi
    else
        if [[ "${#branch_fields[@]}" -eq 1 ]]; then
            remote="_NO_REMOTE_TRACKING_"
            remote_url='.'
        else
            IFS="[,]" read -ra remote_fields <<< "${branch_fields[1]}"
            upstream="${remote_fields[0]}"
            local ahead="" behind=""
            for remote_field in "${remote_fields[@]}"; do
                if [[ "${remote_field}" == "ahead "* ]]; then
                    ahead="_AHEAD_${remote_field:6}"
                fi
                if [[ "${remote_field}" == "behind "* ]] || [[ "${remote_field}" == " behind "* ]]; then
                    local num_behind="${remote_field:7}"
                    behind="_BEHIND_${num_behind# }"
                fi
            done
            remote="${behind}${ahead}"
        fi
    fi

    if [[ -z "${remote:+x}" ]]; then
        remote='.'
    fi

    if [[ -z "${upstream:+x}" ]]; then
        upstream='^'
    fi

    local UPSTREAM_TRIMMED
    UPSTREAM_TRIMMED=$(xargs <<< "$upstream")

    _GIT_STATUS_FIELDS=(
        "${branch}${state}"
        "${remote}"
        "${remote_url}"
        "${UPSTREAM_TRIMMED}"
        "${num_staged}"
        "${num_conflicts}"
        "${num_changed}"
        "${num_untracked}"
        "${num_stashed}"
        "${clean}"
        "${detached_head}"
    )
}