if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH="/root/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh
export LANG=fr_FR.UTF-8
alias update="pacman -Syyu"
alias connect_mick="wpa_supplicant -B -i wlp2s0 -c /etc/wpa_supplicant/wpa_supplicant.conf"
alias disconnect="killall wpa_supplicant"
alias change_mac="disconnect;ip link set wlp2s0 down;ip link set enp5s0 down;macchanger -Ap wlp2s0;macchanger -Ap enp5s0;ip link set wlp2s0 up;ip link set enp5s0 up"
alias firefox="bash -c 'firefox &'; exit"
alias ll="ls -al"
alias discord="bash -c 'discord --no-sandbox &'; exit"
alias virtualbox="bash -c 'virtualbox &'; exit"
alias burpsuite="bash -c 'burpsuite &'; exit"
alias code="bash -c '/usr/share/vscodium/codium --no-sandbox --user-data-dir /root/.vscodium $1 &'; exit"
alias filezilla="filezilla &"
alias steam="bash -c 'steam &'"
alias minecraft="bash -c 'minecraft-launcher &'; exit"
alias wireshark="bash -c 'wireshark &'; exit"
alias hdmi_on="xrandr --output HDMI-1-1 --auto --left-of eDP-1"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
killall flameshot
bash -c 'flameshot &'
clear
