# Aliases
alias t = tree -La 1
alias tt = tree -La 2
alias inv = nvim (fzf --preview 'batcat --color=always --style=numbers --line-range=:500 {}')
alias vim = vim
alias c = clear
alias b = bluetoothctl
alias commit = git commit -m

# Now safe to source files
source ~/.cache/starship.nu
source ~/.cache/zoxide.nu
