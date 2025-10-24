eval "$(zoxide init bash)"

export PATH="/home/dm/.local/bin:$PATH"

export PATH="/home/dm/Public:$PATH"

export SPARK_HOME=/opt/spark

export PATH=$PATH:$SPARK_HOME/bin

alias t='tree -La 1'

alias tt='tree -La 2'

alias inv='nvim $(fzf --preview "batcat --color=always --style=numbers --line-range=:500 {}")'

alias vim='vim'

alias c='clear'

alias b='bluetoothctl'

alias commit='git commit -m'

export PATH="$HOME/.cabal/bin:$PATH"
export PATH="$HOME/.ghcup/bin:$PATH"
export COMPOSE_BAKE=true

eval "$(oh-my-posh init bash --config /home/s/.cache/oh-my-posh/themes/paradox.omp.json)"
