#!/bin/bash
choice=$(printf "Lock\nSleep\nReboot\nShutdown" | rofi -dmenu)

case $choice in
  Lock) hyprlock ;;
  Sleep) hyprlock & sleep 0.3; systemctl suspend ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
esac
