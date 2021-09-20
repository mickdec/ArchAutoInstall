########################################################
# Arch AutoInstaller script with /encryption /Security #
# Author : DECELLE Mickael                             #
# Contact : https://github.com/mickdec/ArchAutoInstall #
########################################################

DISK="/dev/sda"
ENCRYPT="YES"
SSH="YES"
I3="YES"
set -- "-GONNAGOFAST"

PACKETS="base linux linux-firmware sudo nano wget dhcpcd grub openssh firefox"
echo -e 'If you want a faster installation, start this script with \e[94m-GONNAGOFAST \e[32margument.\e[39m'

check_www(){
        echo "Testing your internet connection..."
        if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
                echo "You are perfectly connected to the World Wide Web. Cool."
        else
                echo "You are not connected to the World Wide Web.. Running the manager."
                wifi-menu ens33
                check_www
        fi
}
check_www

EFICHECK=$(ls /sys/firmware/efi/efivars)

if [[ ${#EFICHECK} -ge 20 ]]
then
        VARTYPE="UEFI"
        echo -e "\e[94mUEFI \e[32mtype detected.\e[39m"
else
        VARTYPE="BIOS"
        echo -e "\e[94mBIOS \e[32mtype detected.\e[39m"
fi

check_encrypt(){
        while [[ "$ENCRYPT" != "YES" && "$ENCRYPT" != "NO" ]]
        do
                echo -e '\e[32mDo yo want to encrypt your system ? [YES/NO] :\e[39m'
                read ENCRYPT
                echo -e "\e[32mPlease enter YES or NO in uppercase\e[39m"
                read ENCRYPT
        done
}
check_encrypt


check_i3(){
        if [[ "$I3" != "YES" && "$I3" != "NO" ]]
        then
                echo -e '\e[32mDo yo want install i3 on your system ? [YES/NO] :\e[39m'
                read I3
                echo -e "\e[32mPlease enter YES or NO in uppercase\e[39m"
                check_i3
        fi
}
check_i3


if [[ "$1" == "-GONNAGOFAST" ]]
then
        #VARTIMEZONE=$(curl --fail https://ipapi.co/timezone) NOT WORKING RN
        VARTIMEZONE="Europe/Paris" #FOR ESGI
        VARKBDLAYOUT="azerty"
        VAREFISIZE="512M"
        VARSWAPSIZE="3G"
        VARROOTSIZE="ENDSECTOR"
        VARHOSTNAME="PEN"
else
        echo -e '\e[32mEnter your keyboard layout [azerty|qwerty] :\e[39m'
        read VARKBDLAYOUT
        if [[ "$VARKBDLAYOUT" != "azerty" || "$VARKBDLAYOUT" != "qwerty" ]]
        then
                echo -e '\e[31mBad keyboard layout. Going azerty\e[39m'
                VARKBDLAYOUT="azerty"
                echo $VARKBDLAYOUT 
        fi
        echo -e '\e[32mEnter your time zone [Europe/Paris|auto] :\e[39m'
        read VARTIMEZONE
        if [[ "$VARTIMEZONE" == auto ]]
        then
                VARTIMEZONE=$(curl --fail https://ipapi.co/timezone)
        elif [[ "$VARTIMEZONE" != "Europe/Paris" ]]
        then    
                echo -e '\e[31mBad TimeZone. Going Auto\e[39m'
                VARTIMEZONE=$(curl --fail https://ipapi.co/timezone)
                echo $VARTIMEZONE
        fi
        echo -e '\e[32mEnter EFI partition size [+512M] :\e[39m'
        read VAREFISIZE
        echo -e '\e[32mEnter SWAP partition size [+5G] :\e[39m'
        read VARSWAPSIZE
        echo -e '\e[32mEnter / partition size [ENDSECTOR] :\e[39m'
        read VARROOTSIZE
        if [[ "$ENCRYPT" != "YES" || "$ENCRYPT" != "NO" ]]
        then
                echo -e '\e[31mBad Encrypt. Going YES\e[39m'
                ENCRYPT="YES"
                echo $ENCRYPT
        fi
        echo -e '\e[32mEnter Hostname :\e[39m'
        read VARHOSTNAME
fi
echo -e '\e[31mVariables resume :\e[39m'
echo -e '\e[31mInstall Type :\e[39m' $VARTYPE
echo -e '\e[31mTimeZone :\e[39m' $VARTIMEZONE
echo -e '\e[31mKeyboard Layout :\e[39m' $VARKBDLAYOUT
echo -e '\e[31mEFI Size :\e[39m' $VAREFISIZE
echo -e '\e[31mSWAP Size :\e[39m' $VARSWAPSIZE
echo -e '\e[31m/ Size :\e[39m' $VARROOTSIZE
echo -e '\e[31mEncrypting :\e[39m' $ENCRYPT
echo -e '\e[31mi3 :\e[39m' $I3
echo -e '\e[31mHostname :\e[39m' $VARHOSTNAME
echo -e '\e[32mPRESS ENTER TO START THE INSTALLATION\e[39m'
read DUMMY

if [[ "$VARTYPE" == "BIOS" && "$ENCRYPT" == "YES" ]]
then
        echo "Didn't supporting BIOS with encrypted partition atm..."
        exit
fi

if [[ "$VARKBDLAYOUT" == "azerty" ]]
then
        echo -e '\e[32m=> \e[94m Change Keyboard AZERTY FR\e[39m'
        loadkeys /usr/share/kbd/keymaps/i386/azerty/fr-latin9.map.gz #Change Keyboard AZERTY FR
fi

echo -e '\e[32m=> \e[94m Set timestamp locale\e[39m'
timedatectl set-ntp true #Set timestamp locale

echo -e '\e[32m=> \e[94m Set time zone to '$VARTIMEZONE'\e[39m'
timedatectl set-timezone $VARTIMEZONE #Set time zone to Europe Paris

ls /dev/sd*
echo -e '\e[32mWhat disk do you want to use for the installation ? :\e[39m'
read DISK

echo -e '\e[32m=> \e[94m Create partitions\e[39m'
uefi_parts(){
        (
        echo o      #New disklabel
        #EFI
        echo n      #New Partition
        echo p      #Primary
        echo 1      #First partition
        echo        #Default Sector start
        echo +$VAREFISIZE  #512MiB
        echo t      #Change type
        echo ef     #EFI
        #SWAP
        echo n      #New Partition
        echo p      #Primary
        echo 2      #Second partition
        echo        #Default Sector start
        echo +$VARSWAPSIZE    #5Gigas
        echo t      #Change type
        echo 2      #Second partition
        echo 82     #Linux SWAP
        #ROOT
        echo n      #New Partition
        echo p      #Primary
        echo 3      #Third partition
        echo        #Default Sector start
        echo 
        echo t      #Change type
        echo 3      #Third partition
        echo 83     #Linux
        #WRITE
        echo w
        ) | sudo fdisk --wipe-partitions always $DISK #Start fdisk with all preceding commands
}
bios_parts(){
        (
        echo o      #New disklabel
        #SWAP
        echo n      #New Partition
        echo p      #Primary
        echo 1      #First partition
        echo        #Default Sector start
        echo +$VARSWAPSIZE    #5Gigas
        echo t      #Change type
        echo 82     #Linux SWAP
        #ROOT
        echo n      #New Partition
        echo p      #Primary
        echo 2      #Second partition
        echo        #Default Sector start
        echo 
        echo t      #Change type
        echo 2      #Second partition
        echo 83     #Linux
        #WRITE
        echo w
        ) | sudo fdisk --wipe-partitions always $DISK #Start fdisk with all preceding commands
}

if [[ "$VARTYPE" == "UEFI" ]]
then
        uefi_parts
else
        bios_parts
fi


if [[ "$ENCRYPT" == "YES" ]]
then
        if [[ "$VARTYPE" == "UEFI" ]]
        then
                echo -e '\e[32m=> \e[94m Encrypting '$DISK'3 PLEASE ENTER A PASSWORD\e[39m'
                cryptsetup -q -v --type luks1 -c aes-xts-plain64 -s 512 --hash sha512 -i 5000 --use-random luksFormat "$DISK"3 #Encrypt /root
                echo -e '\e[32m=> \e[94m Openning '$DISK'3\e[39m'
                cryptsetup luksOpen "$DISK"3 c_sda3 #Open /root and create mapper
        else
                echo -e '\e[32m=> \e[94m Encrypting '$DISK'2 PLEASE ENTER A PASSWORD\e[39m'
                cryptsetup -q -v --type luks1 -c aes-xts-plain64 -s 512 --hash sha512 -i 5000 --use-random luksFormat "$DISK"2 #Encrypt /root
                echo -e '\e[32m=> \e[94m Openning '$DISK'2\e[39m'
                cryptsetup luksOpen "$DISK"2 c_sda2 #Open /root and create mapper
        fi
fi

if [[ "$VARTYPE" == "UEFI" ]]
then 
                echo -e '\e[32m=> \e[94m Formating EFI Fat32\e[39m'
                mkfs.fat -F32 "$DISK"1 #Formating EFI Fat32
fi

if [[ "$ENCRYPT" == "YES" ]]
then
        if [[ "$VARTYPE" == "UEFI" ]]
        then
                echo -e '\e[32m=> \e[94m Formating Encrypted /root EXT4\e[39m'
                mkfs.ext4 /dev/mapper/c_sda3 #Formating Encrypted /root EXT4
        else
                echo -e '\e[32m=> \e[94m Formating Encrypted /root EXT4\e[39m'
                mkfs.ext4 /dev/mapper/c_sda2 #Formating Encrypted /root EXT4
        fi
else
        if [[ "$VARTYPE" == "UEFI" ]]
        then
                echo -e '\e[32m=> \e[94m Formating /root EXT4\e[39m'
                mkfs.ext4 "$DISK"3 #Formating /root EXT4
        else
                echo -e '\e[32m=> \e[94m Formating /root EXT4\e[39m'
                mkfs.ext4 "$DISK"2 #Formating /root EXT4
        fi
fi

if [[ "$VARTYPE" == "UEFI" ]]
then
        echo -e '\e[32m=> \e[94m Setting Swap for SWAP Partition\e[39m'
        mkswap "$DISK"2 #Setting Swap for SWAP Partition

        echo -e '\e[32m=> \e[94m Enabling SWAP\e[39m'
        swapon "$DISK"2 #Enabling SWAP
else
        echo -e '\e[32m=> \e[94m Setting Swap for SWAP Partition\e[39m'
        mkswap "$DISK"1 #Setting Swap for SWAP Partition

        echo -e '\e[32m=> \e[94m Enabling SWAP\e[39m'
        swapon "$DISK"1 #Enabling SWAP
fi

if [[ "$ENCRYPT" == "YES" ]]
then
        if [[ "$VARTYPE" == "UEFI" ]]
        then
                echo -e '\e[32m=> \e[94m Mounting Encrypted root\e[39m'
                mount /dev/mapper/c_sda3 /mnt #Mounting Encrypted root
        else
                echo -e '\e[32m=> \e[94m Mounting Encrypted root\e[39m'
                mount /dev/mapper/c_sda2 /mnt #Mounting Encrypted root
        fi
else
        if [[ "$VARTYPE" == "UEFI" ]]
        then
                echo -e '\e[32m=> \e[94m Mounting root\e[39m'
                mount "$DISK"3 /mnt #Mounting root
        else
                echo -e '\e[32m=> \e[94m Mounting root\e[39m'
                mount "$DISK"2 /mnt #Mounting root
        fi
fi

echo -e '\e[32m=> \e[94m Creating /boot Directory\e[39m'
mkdir /mnt/boot #Creating /boot Directory

if [[ "$VARTYPE" == "UEFI" ]]
then
        echo -e '\e[32m=> \e[94m Mount EFI\e[39m'
        mount "$DISK"1 /mnt/boot #Mounting EFI to /boot
fi

if [[ "$VARTIMEZONE" == "Europe/Paris" ]]
then
        echo -e '\e[32m=> \e[94m Get Best mirorlist for France\e[39m'
        curl -s "https://archlinux.org/mirrorlist/?country=FR&protocol=https&use_mirror_status=on" > /etc/pacman.d/mirrorlist #Get Best mirorlist for France

        echo -e '\e[32m=> \e[94m Removing Comment section of MirrorList\e[39m'
        sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist #Removing Comment section of MirrorList
fi

if [[ "$VARTYPE" == "UEFI" ]]
then
        echo -e '\e[32m=> \e[94m Installing Linux and all additionnal packages to /\e[39m'
        pacstrap /mnt $PACKETS efibootmgr #Installing Linux and all additionnal packages to /
else
        echo -e '\e[32m=> \e[94m Installing Linux and all additionnal packages to /\e[39m'
        pacstrap /mnt $PACKETS #Installing Linux and all additionnal packages to /
fi

echo -e '\e[32m=> \e[94m Generate fstab\e[39m'
genfstab -U /mnt >> /mnt/etc/fstab #Generate fstab

echo -e '\e[32m=> \e[94m Generate Local AutoInstall2.sh\e[39m'
echo "echo -e '\e[32m=> \e[94m Create Link with zoneinfo "$VARTIMEZONE" to /etc/localtime\e[39m'
ln -sf /usr/share/zoneinfo/"$VARTIMEZONE" /etc/localtime #Create Link with zoneinfo "$VARTIMEZONE" to /etc/localtime

echo -e '\e[32m=> \e[94m Setting the time clock\e[39m'
hwclock --systohc #Setting the time clock

echo -e '\e[32m=> \e[94m Uncomment locale region\e[39m'" >> /mnt/AutoInstall2.sh #Generate Local AutoInstall2.sh

if [[ "$VARTIMEZONE" == "Europe/Paris" ]]
then
        echo "sed -i 's/#fr_FR.UTF-8/fr_FR.UTF-8/g' /etc/locale.gen #Uncomment locale region" >> /mnt/AutoInstall2.sh
else    
        echo "sed -i 's/#en_EN.UTF-8/en_EN.UTF-8/g' /etc/locale.gen #Uncomment locale region" >> /mnt/AutoInstall2.sh
fi

if [[ "$SSH" == "YES" ]]
then
        echo "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config" >> /mnt/AutoInstall2.sh
fi

if [[ "$VARKBDLAYOUT" == "azerty" ]]
then
        echo "echo -e '\e[32m=> \e[94m Creating persistent keyboard configuration file\e[39m'
echo KEYMAP=fr-latin9 >> /etc/vconsole.conf #Creating persistent keyboard configuration file" >> /mnt/AutoInstall2.sh
else    
        echo "echo -e '\e[32m=> \e[94m Creating persistent keyboard configuration file\e[39m'
echo KEYMAP=en-latin9 >> /etc/vconsole.conf #Creating persistent keyboard configuration file" >> /mnt/AutoInstall2.sh
fi

echo "echo -e '\e[32m=> \e[94m Creating hostname\e[39m'
echo "$VARHOSTNAME" >> /etc/hostname #Creating hostname

echo -e '\e[32m=> \e[94m Creating hosts file with ipv4 localhost\e[39m'
echo 127.0.0.1 localhost >> /etc/hosts #Creating hosts file with ipv4 localhost

echo -e '\e[32m=> \e[94m Updating host file for ipv6 localhost\e[39m'
echo ::1 localhost >> /etc/hosts #Updating host file for ipv6 localhost

echo -e '\e[32m=> \e[94m Updating host file for localdomain\e[39m'
echo 127.0.1.1 "$VARHOSTNAME".localdomain "$VARHOSTNAME" >> /etc/hosts #Updating host file for localdomain

echo -e '\e[32m=> \e[94m Enabling DHCPCD Service\e[39m'
systemctl enable dhcpcd #Enabling DHCPCD Service" >> /mnt/AutoInstall2.sh

if [[ "$SSH" == "YES" ]]
then
        echo "echo -e '\e[32m=> \e[94m Enabling SSH Service\e[39m'
        systemctl enable sshd #Enabling sshd Service" >> /mnt/AutoInstall2.sh
fi

echo "echo -e '\e[32m=> \e[94m Enabling Hook config\e[39m'" >> /mnt/AutoInstall2.sh

if [[ "$ENCRYPT" == "YES" ]]
then
    echo "sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect keyboard keymap modconf block encrypt filesystems fsck)/g' /etc/mkinitcpio.conf #Enabling Crypto keyboard ... Hook config" >> /mnt/AutoInstall2.sh
else
    echo "sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect keyboard keymap modconf block filesystems fsck)/g' /etc/mkinitcpio.conf #Enabling keyboard ... Hook config" >> /mnt/AutoInstall2.sh
fi

echo "echo -e '\e[32m=> \e[94m Create mkinitcpio\e[39m'
mkinitcpio -P #Create mkinitcpio

echo -e '\e[32m=> \e[94m Change root password, Please Enter a ROOT password\e[39m'
passwd #Change root password" >> /mnt/AutoInstall2.sh

if [[ "$VARTYPE" == "UEFI" ]]
then
        echo "echo -e '\e[32m=> \e[94m Install Bootloader\e[39m'
grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB #Install Bootloader" >> /mnt/AutoInstall2.sh
else
        #GRUB Install Error HERE with BIOS+ENCRYPT, Dont know why.
        echo "echo -e '\e[32m=> \e[94m Install Bootloader\e[39m'
grub-install --target=i386-pc "$DISK" #Install Bootloader" >> /mnt/AutoInstall2.sh 
fi


if [[ "$ENCRYPT" == "YES" ]]
then
        echo "echo -e '\e[32m=> \e[94m Enabling Cryptodisk in GRUB\e[39m'
sed -i 's/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g' /etc/default/grub #Enabling Cryptodisk in GRUB

echo -e '\e[32m=> \e[94m Adding Preload_modules in GRUB\e[39m'
sed -i 's/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos\"/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks cryptodisk\"/g' /etc/default/grub #Adding Preload_modules in GRUB" >> /mnt/AutoInstall2.sh

        if [[ "$VARTYPE" == "UEFI" ]]
        then
        echo "echo -e '\e[32m=> \e[94m Adding Linux CMDLINE in GRUB\e[39m'
GUIDMAPPER=$(blkid | grep ^"$DISK"3 | awk -F "\"" '{print $2}') #Get device GUID
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID='\"\$GUIDMAPPER\"':c_sda3 root=\/dev\/mapper\/c_sda3 crypto=whirlpool:aes-xts-plain64:512:0: apparmor=1 lsm=lockdown,yama,apparmor security=selinux selinux=1\"/g' /etc/default/grub #Adding Linux CMDLINE in GRUB" >> /mnt/AutoInstall2.sh
        else
                echo "echo -e '\e[32m=> \e[94m Adding Linux CMDLINE in GRUB\e[39m'
GUIDMAPPER=$(blkid | grep ^"$DISK"2 | awk -F "\"" '{print $2}') #Get device GUID
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID='\"\$GUIDMAPPER\"':c_sda2 root=\/dev\/mapper\/c_sda2 crypto=whirlpool:aes-xts-plain64:512:0: apparmor=1 lsm=lockdown,yama,apparmor security=selinux selinux=1\"/g' /etc/default/grub #Adding Linux CMDLINE in GRUB" >> /mnt/AutoInstall2.sh
        fi
fi

echo "echo -e '\e[32m=> \e[94m Create grub config file\e[39m'
grub-mkconfig -o /boot/grub/grub.cfg #Create grub config file

exit" >> /mnt/AutoInstall2.sh #Generate Local AutoInstall2.sh


if [[ "$I3" == "YES" ]]
then
        echo "pacman --noconfirm -S feh which zsh git apparmor rxvt-unicode xorg-xinit xorg-server xorg-setxkbmap i3-gaps i3status xorg-fonts-type1 ttf-dejavu gsfonts sdl_ttf ttf-bitstream-vera ttf-liberation ttf-freefont ttf-arphic-uming ttf-baekmuk
cp /etc/X11/xinit/xinitrc ~/.xinitrc
for i in 1 2 3 4 5
do
  sed -i '\$d' ~/.xinitrc
done
echo \"setxkbmap fr
export TERMINAL=urxvt
exec i3\" >> ~/.xinitrc" >> /mnt/AutoConfig.sh

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

curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.p10k.zsh > /root/.p10k.zsh
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.zshrc > /root/.zshrc
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.bashrc > /root/.bashrc
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.bash_profile > /root/.bash_profile
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/.Xresources > /root/.Xresources
mkdir /root/.config
mkdir /root/.config/i3
curl -L https://raw.githubusercontent.com/mickdec/ArchAutoInstall/master/CONF/config > /root/.config/i3/config

wget https://raw.githubusercontent.com/mickdec/Esper/master/RES/READMERES/Esper-1920x1080.png?token=AH352UXZSQPPWXIQACUD5TDBKHFG2 -O /root/.config/bg.jpg

#sudo pacman -S lightdm lightdm-gtk-greeter -y
#systemctl enable lightdm" >> /mnt/AutoConfig.sh
fi

echo -e '\e[32m=> \e[94m chmod 777 /mnt/AutoInstall2.sh\e[39m'
chmod 777 /mnt/AutoInstall2.sh

echo -e '\e[32m=> \e[94m Starting AutoInstall2.sh in chroot\e[39m'
arch-chroot /mnt ./AutoInstall2.sh

echo -e '\e[32m=> \e[94mRemoving AutoInstall2.sh\e[39m'
rm -Rf /mnt/AutoInstall2.sh


if [[ "$I3" == "YES" ]]
then
        echo -e '\e[32m=> \e[94m chmod 777 /mnt/AutoConfig.sh\e[39m'
        chmod 777 /mnt/AutoConfig.sh

        echo -e '\e[32m=> \e[94m Starting AutoConfig.sh for i3 in chroot\e[39m'
        arch-chroot /mnt ./AutoConfig.sh
fi

echo -e '\e[32m=> \e[94m Unmounting /mnt\e[39m'
umount -R /mnt #Unmount every partitions

echo -e '\e[32mInstallation Finished without errors, shutdown in 10 Seconds\e[39m'
echo -e "\e[32mDon't forget to remove your liveCD\e[39m"
sleep 10

echo -e '\e[32mShuting down now\e[39m'
shutdown now #shutdown