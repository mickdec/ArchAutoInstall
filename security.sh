chmod 444 /etc/ssh/sshd_config
chmod 700 /root

chmod 027 /etc/profile

pacman -S docker nmap usbguard rkhunter

# burpsuite crunch patator wireshark

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

echo "#################################################################
#                   _    _           _   _                      #
#                  / \  | | ___ _ __| |_| |                     #
#                 / _ \ | |/ _ \ '__| __| |                     #
#                / ___ \| |  __/ |  | |_|_|                     #
#               /_/   \_\_|\___|_|   \__(_)                     #
#                                                               #
#  You are entering into a secured area! Your IP, Login Time,   #
#   Username has been noted and has been sent to the server     #
#                       administrator!                          #
#   This service is restricted to authorized users only. All    #
#            activities on this system are logged.              #
#  Unauthorized access will be fully investigated and reported  #
#        to the appropriate law enforcement agencies.           #
#################################################################" > /etc/issue.net

echo "#################################################################
#                   _    _           _   _                      #
#                  / \  | | ___ _ __| |_| |                     #
#                 / _ \ | |/ _ \ '__| __| |                     #
#                / ___ \| |  __/ |  | |_|_|                     #
#               /_/   \_\_|\___|_|   \__(_)                     #
#                                                               #
#  You are entering into a secured area! Your IP, Login Time,   #
#   Username has been noted and has been sent to the server     #
#                       administrator!                          #
#   This service is restricted to authorized users only. All    #
#            activities on this system are logged.              #
#  Unauthorized access will be fully investigated and reported  #
#        to the appropriate law enforcement agencies.           #
#################################################################" > /etc/issue

echo "Banner /etc/issue.net
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
AllowTcpForwarding no" > /etc/ssh/sshd_config