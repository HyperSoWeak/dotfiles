#!/bin/bash
choice=$(printf "Lock\nSleep\nReboot\nShutdown" | rofi -dmenu)

case $choice in
  Lock) hyprlock ;;
  Sleep) hyprlock && systemctl suspend ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
esac
