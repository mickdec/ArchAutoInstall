if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH="/root/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh
export LANG=fr_FR.UTF-8
#alias vlc="'bash -c vlc'; exit"
alias update="pacman -Syyu"
alias connect_mick="wpa_supplicant -B -i wlp2s0 -c /etc/wpa_supplicant/wpa_supplicant.conf"
alias connect_esgi="wpa_supplicant -B -i wlp2s0 -c /etc/wpa_supplicant/wpa_supplicant_esgi.conf"
alias firefox="bash -c 'firefox &'; exit"
alias ll="ls -al"
alias discord="bash -c 'discord --no-sandbox &'; exit"
alias virtualbox="bash -c 'virtualbox &'; exit"
alias burpsuite="bash -c 'burpsuite &'; exit"
alias code="bash -c '/usr/share/vscodium/codium --no-sandbox $1 &'; exit"
alias filezilla="filezilla &"
alias steam="bash -c 'steam &'"
alias minecraft="bash -c 'minecraft-launcher &'; exit"
alias wireshark="bash -c 'wireshark &'; exit"
alias hdmi_on="xrandr --output HDMI-1-1 --auto --left-of eDP-1"
alias vps="ssh -o ServerAliveInterval=30 root@51.210.109.138 -p 2910"
# alias teams="./usr/share/teams/teams --no-sandbox"
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
