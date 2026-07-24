{
  config,
  lib,
  pkgs,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };
  anthropic-skills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "2c7ec5e78b8e5d43ea02e90bb8826f6b9f147b0c";
    hash = "sha256-BMgH43diojdUrGC6ivk87eEm2W1yWNuh2fpR9JpbUnE=";
  };
  trailofbits-skills = pkgs.fetchFromGitHub {
    owner = "trailofbits";
    repo = "skills";
    rev = "e8cc5baf9329ccb491bfa200e82eacbac83b1ead";
    hash = "sha256-ahuJDSIpUW2Zl5SbhyWXwMLFCYIjPygQPSfFeISXdHc=";
  };
  oh-pi = pkgs.fetchFromGitHub {
    owner = "ifiokjr";
    repo = "oh-pi";
    rev = "e431647671f88534e6d23576d4e495cf99eda06a";
    hash = "sha256-ydTCWMins5mC7n7/MdpVz3N5Kt+x2FFtkOQgWLNlltk=";
  };
in
lib.mkIf config.misha.shell.llms.enable {
  home.packages = with pkgs; [
    extra-node.pi-acp
    # Scripts
    (writeShellApplication {
      name = "pi-commit";
      text = ''
        t="$(mktemp)"
        { (cat <<"EOF"
        Non-interactively generate a commit message for the following changes.
        Your output is piped to `git commit -F -`, so it directly becomes the commit message.
        The block describing the commit message starts when you write ```commit, and continues until the end of your response.
        Follow conventional commits format:
        ```commit
        type(scope): description

        [optional body]
        ```

        Types: feat, fix, refactor, docs, test, chore, perf, ci, style, build

        - Try to keep the subject line under 72 characters
        - Use imperative mood ("add" not "added")
        - Body explains WHY, not WHAT (the diff shows what)

        ------
        EOF
        git diff --cached) | pi --thinking low --no-extensions --no-skills --provider openrouter --model openrouter/free --no-session --tools read,grep,find,ls -p | tee "$t"; } || { rm -f "$t"; exit 1; }
        python3 - "$t" <<"EOF"
        import sys
        from pathlib import Path
        import subprocess
        p = Path(sys.argv[1])
        lines = p.read_text().splitlines()

        try:
            lines = lines[lines.index("```commit")+1:]
        except ValueError:
            sys.exit(1)

        try:
            lines = lines[:lines.index("```")]
        except ValueError:
            pass

        while not lines[-1].strip():
            lines.pop()

        commit_message = "\n".join(lines) + "\n"
        p = subprocess.Popen(["git", "commit", "-F", "-"], stdin=subprocess.PIPE)
        _ = p.communicate(commit_message.encode("utf-8"))
        sys.exit(p.returncode)
        EOF
        git show --stat HEAD
      '';
      runtimeInputs = [
        python3
        git
      ];
    })
  ];
  programs.pi-coding-agent = {
    enable = true;
    settings = {
      theme = "light";
      defaultProvider = "openrouter";
      enabledModels = [
        "deepseek/deepseek-v4-flash"
        "deepseek/deepseek-v4-pro"
        "llama.cpp/unsloth/gemma-4-12B-it-qat-GGUF:UD-Q4_K_XL"
      ];
      defaultThinkingLevel = "medium";
      packages = [
        "npm:pi-subagents"
        "npm:pi-mcp-adapter"
      ];
    };
    skills = {
      skill-creator.source = anthropic-skills + "/skills/skill-creator";
      pdf.source = anthropic-skills + "/skills/pdf";
      modern-python.source = trailofbits-skills + "/plugins/modern-python/skills/modern-python";
      skill-extractor.source = toString ./skills/skill-extractor;
      web-search.source = oh-pi + "/packages/skills/skills/web-search";
      web-fetch.source = oh-pi + "/packages/skills/skills/web-fetch";
    };
    promptTemplates = {
      commit = builtins.readFile (oh-pi + "/packages/prompts/prompts/commit.md");
    };
  };
  home.file.".pi/agent/mcp.json".source = jsonFormat.generate "pi-mcp" {
    mcpServers = {
      chrome-devtools = {
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "chrome-devtools-mcp@latest"
          "--no-usage-statistics"
          "--executable-path"
          "${pkgs.chromium}/bin/chromium"
        ];
      };
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      };
    };
  };
}
