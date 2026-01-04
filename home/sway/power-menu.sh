while true; do
    ACTION=$(echo -e "Suspend\nLeave\nReboot\nShutdown\nLock\nExit script" | wofi --show=dmenu -p "Choose an action:")

    case "$ACTION" in
        Suspend)
            exec systemctl suspend
            ;;
        Leave)
            exec swaymsg exit
            ;;
        Reboot)
            exec systemctl reboot
            ;;
        Shutdown)
            exec systemctl poweroff
            ;;
        Lock)
            exec loginctl lock-session
            ;;
        Exit\ script)
            exit 0
            ;;
        *)
            ;;
    esac
done
