# #!/bin/bash
# sleep 1
# killall xdg-desktop-portal-hyprland
# killall xdg-desktop-portal-gnome
# killall xdg-desktop-portal-kde
# killall xdg-desktop-portal-lxqt
# killall xdg-desktop-portal-wlr
# killall xdg-desktop-portal
# sleep 1
# /usr/lib/xdg-desktop-portal-hyprland &
# sleep 2

/#!/bin/bash
sleep 1
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-hyprland &
sleep 3
/usr/lib/xdg-desktop-portal &