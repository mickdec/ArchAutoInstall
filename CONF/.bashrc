export SHELL=$(which zsh)
export LANG=fr_FR.UTF-8
export LC_ALL=fr_FR.UTF-8
sysctl dev.tty.ldisc_autoload=0
sysctl fs.protected_regular=2
sysctl fs.suid_dumpable=0
sysctl kernel.kptr_restrict=2
sysctl kernel.modules_disabled=1
sysctl kernel.perf_event_paranoid=3
sysctl kernel.sysrq=0
sysctl kernel.unprivileged_bpf_disabled=1
sysctl net.core.bpf_jit_harden=2
sysctl net.ipv4.conf.all.accept_redirects=0
sysctl net.ipv4.conf.all.log_martians=1
sysctl net.ipv4.conf.all.rp_filter=1
sysctl net.ipv4.conf.all.send_redirects=0
sysctl net.ipv4.conf.default.accept_redirects=0
sysctl net.ipv4.conf.default.log_martians=1
sysctl net.ipv6.conf.all.accept_redirects=0
sysctl net.ipv6.conf.default.accept_redirects=0
pulseaudio -D
startx
systcl fs.protected_fifos=2
