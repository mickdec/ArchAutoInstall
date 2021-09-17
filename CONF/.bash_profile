if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

if [ -o interactive ] && [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi
