pacman --noconfirm -S xterm xorg-xinit xorg-server i3-wm i3status xorg-fonts-type1 ttf-dejavu font-bh-ttf font-bitstream-speedo gsfonts sdl_ttf ttf-bitstream-vera ttf-liberation ttf-freefont ttf-arphic-uming ttf-baekmuk
cp /etc/X11/xinit/xinitrc ~/.xinitrc
for i in 1 2 3 4 5
do
  sed -i '$d' ~/.xinitrc
done
echo "export TERMINAL=xterm
exec i3" >> ~/.xinitrc

echo "[Unit]
Description=startx automatique pour l'utilisateur %I
After=graphical.target systemd-user-sessions.service

[Service]
User=%I
WorkingDirectory=%h
PAMName=login
Type=simple
ExecStart=/bin/bash -l -c startx

[Install]
WantedBy=graphical.target" >> /etc/systemd/system/startx@.service

systemctl enable startx@root.service

echo 'Section "InputDevice"
Identifier "Generic Keyboard"
Driver "kbd"
Option "CoreKeyboard"
Option "XkbRules" "xorg"
Option "XkbModel" "pc105"
Option "XkbLayout" "fr"
Option "XkbVariant" "latin9"
EndSection' >> /etc/X11/xorg.conf