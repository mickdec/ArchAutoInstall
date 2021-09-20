export SHELL=$(which zsh)
if [[ -o login ]]
then
    exec zsh -l
else
    exec zsh
fi