loadkeys /usr/share/kbd/keymaps/i386/azerty/fr-latin9.map.gz
timedatectl set-ntp true
timedatectl set-timezone Europe/Paris
timedatectl
# (
# echo o
# echo n
# echo
# echo
# echo +512M
# echo t
# echo ef
# echo n
# echo
# echo
# echo +5G
# echo t
# echo 2
# echo 82
# echo n
# echo
# echo
# echo 
# echo t
# echo 3
# echo 83
# echo w
# ) | sudo fdisk --wipe-partitions always /dev/nvme0n1
sudo fdisk --wipe-partitions always /dev/nvme0n1
cryptsetup -q -v --type luks1 -c aes-xts-plain64 -s 512 --hash sha512 -i 5000 --use-random luksFormat "/dev/nvme0n1p3" #Encrypt /root
cryptsetup luksOpen "/dev/nvme0n1p3" c_3
mkfs.fat -F32 "/dev/nvme0n1p1"
mkfs.ext4 /dev/mapper/c_3
mkswap "/dev/nvme0n1p2"
swapon "/dev/nvme0n1p2"
mount /dev/mapper/c_3 /mnt
mkdir /mnt/boot
mount "/dev/nvme0n1p1" /mnt/boot
curl -s "https://archlinux.org/mirrorlist/?country=FR&protocol=https&use_mirror_status=on" > /etc/pacman.d/mirrorlist
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
pacstrap -K /mnt base linux linux-firmware wpa_supplicant sudo nano wget dhcpcd grub openssh ntfs-3g pulseaudio make gcc noto-fonts-cjk efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab

echo "ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
sed -i 's/#fr_FR.UTF-8/fr_FR.UTF-8/g' /etc/locale.gen
echo KEYMAP=fr-latin9 >> /etc/vconsole.conf
echo SLAYER >> /etc/hostname
echo 127.0.0.1 localhost >> /etc/hosts
echo ::1 localhost >> /etc/hosts
echo 127.0.1.1 SLAYER.localdomain SLAYER >> /etc/hosts
systemctl enable dhcpcd
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect keyboard keymap modconf block encrypt filesystems fsck)/g' /etc/mkinitcpio.conf
mkinitcpio -P
passwd
grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB
sed -i 's/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g' /etc/default/grub
sed -i 's/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos\"/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks cryptodisk\"/g' /etc/default/grub
GUIDMAPPER=$(blkid | grep /dev/nvme0n1p3 | awk -F "\"" '{print $2}') #Get device GUID
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID='\"\$GUIDMAPPER\"':c_3 root=\/dev\/mapper\/c_3 crypto=whirlpool:aes-xts-plain64:512:0: apparmor=1 lsm=lockdown,yama,apparmor security=selinux selinux=1\"/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg #Create grub config file
exit" >> /mnt/AutoInstall2.sh

echo "pacman --noconfirm -Sy feh which zsh git apparmor rxvt-unicode xorg-xinit xorg-server xorg-setxkbmap i3-gaps i3status xorg-fonts-type1 ttf-dejavu gsfonts sdl_ttf ttf-bitstream-vera ttf-liberation ttf-freefont ttf-arphic-uming ttf-baekmuk" >> /mnt/AutoConfig.sh
echo "echo \"[Unit]
Description=startx automatique pour l'utilisateur %I
After=graphical.target systemd-user-sessions.service

[Service]
User=%I
WorkingDirectory=%h
PAMName=login
Type=simple
ExecStart=/bin/bash -l -c startx

[Install]
WantedBy=graphical.target\" >> /etc/systemd/system/startx@.service
systemctl enable startx@root.service

echo 'Section \"InputDevice\"
Identifier \"Generic Keyboard\"
Driver \"kbd\"
Option \"CoreKeyboard\"
Option \"XkbRules\" \"xorg\"
Option \"XkbModel\" \"pc105\"
Option \"XkbLayout\" \"fr\"
Option \"XkbVariant\" \"latin9\"
EndSection' >> /etc/X11/xorg.conf.d/00-keyboard.conf

curl -L http://install.ohmyz.sh/ | sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.bash_profile > /root/.bash_profile
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.bashrc > /root/.bashrc
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.p10k.zsh > /root/.p10k.zsh
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.Xdefaults > /root/.Xdefaults
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.xinitrc > /root/.xinitrc
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.Xresources > /root/.Xresources
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.zshrc > /root/.zshrc
mkdir /root/.config
mkdir /root/.config/i3
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/config > /root/.config/i3/config

wget https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/Esper-1920x1080.png -O /root/.config/bg.jpg
sudo pacman --noconfirm -Sy i3lock
mkdir /root/.config/i3status
wget https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/config-status -O /root/.config/i3status/config" >> /mnt/AutoConfig.sh

chmod 777 /mnt/AutoInstall2.sh
arch-chroot /mnt ./AutoInstall2.sh
chmod 777 /mnt/AutoConfig.sh
arch-chroot /mnt ./AutoConfig.sh

echo "chmod 444 /etc/ssh/sshd_config
chmod 700 /root
chmod 027 /etc/profile
pacman -S docker nmap usbguard rkhunter wireshark-qt fail2ban arch-audit macchanger fakeroot jre17-openjdk gnu-netcat tcpdump
systemctl disable sshd
systemctl disable docker.service
systemctl enable apparmor
systemctl enable shadow.service
systemctl enable systemd-rfkill.service
systemctl enable systemd-ask-password-console.service
systemctl enable systemd-ask-password-wall.service
systemctl enable rescue.service
systemctl enable emergency.service
systemctl enable systemd-rfkill.service
systemctl enable dm-event.service
systemctl enable auditd.service
echo '*               hard    core            0' >> /etc/security/limits.conf
echo \"#################################################################
#                   _    _           _   _                      #
#                  / \\  | | ___ _ __| |_| |                    #
#                 / _ \\ | |/ _ \\ '__| __| |                   #
#                / ___ \\| |  __/ |  | |_|_|                    #
#               /_/   \\_\\_|\\___|_|   \\__(_)                 #
#                                                               #
#  You are entering into a secured area! Your IP, Login Time,   #
#   Username has been noted and has been sent to the server     #
#                       administrator!                          #
#   This service is restricted to authorized users only. All    #
#            activities on this system are logged.              #
#  Unauthorized access will be fully investigated and reported  #
#        to the appropriate law enforcement agencies.           #
#################################################################\" > /etc/issue.net

echo \"#################################################################
#                   _    _           _   _                      #
#                  / \\  | | ___ _ __| |_| |                    #
#                 / _ \\ | |/ _ \\ '__| __| |                   #
#                / ___ \\| |  __/ |  | |_|_|                    #
#               /_/   \\_\\_|\\___|_|   \\__(_)                 #
#                                                               #
#  You are entering into a secured area! Your IP, Login Time,   #
#   Username has been noted and has been sent to the server     #
#                       administrator!                          #
#   This service is restricted to authorized users only. All    #
#            activities on this system are logged.              #
#  Unauthorized access will be fully investigated and reported  #
#        to the appropriate law enforcement agencies.           #
#################################################################\" > /etc/issue

echo \"Banner /etc/issue.net
Port 22
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTHPRIV
AuthorizedKeysFile	.ssh/authorized_keys
PasswordAuthentication yes
ChallengeResponseAuthentication no
GSSAPIAuthentication yes
GSSAPICleanupCredentials no
UsePAM yes
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
Subsystem	sftp	/usr/libexec/openssh/sftp-server
AllowAgentForwarding no
X11Forwarding no
UseDNS no
TCPKeepAlive no
PermitRootLogin yes
MaxSessions 2
MaxAuthTries 3
LogLevel verbose
Compression no
ClientAliveCountMax 2
AllowTcpForwarding no\" > /etc/ssh/sshd_config
wget https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/jail.local -O /etc/fail2ban/jail.local" >> /mnt/Security.sh

chmod 777 /mnt/Security.sh
arch-chroot /mnt ./Security.sh

rm -Rf /mnt/AutoInstall2.sh
rm -Rf /mnt/Security.sh
rm -Rf /mnt/AutoConfig.sh

umount -R /mnt
shutdown now