eval "$(starship init bash)"

eval "$(zoxide init bash)"

export PATH="/home/dm/.local/bin:$PATH"

export PATH="/home/dm/Public:$PATH"

export SPARK_HOME=/opt/spark

export PATH=$PATH:$SPARK_HOME/bin

alias t='tree -La 1'

alias tt='tree -La 2'

alias inv='nvim $(fzf --preview "batcat --color=always --style=numbers --line-range=:500 {}")'

alias vim='nvim'

alias c='clear'

alias b='bluetoothctl'

alias commit='git commit -m'
