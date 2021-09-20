if [ -z "${NOZSH}" ] && type zsh &> /dev/null
then
    export SHELL=$(which zsh)
    if [[ -o login ]]
    then
        exec zsh -l
    else
        exec zsh
    fi
fi