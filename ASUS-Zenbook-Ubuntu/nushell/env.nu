# Set CABAL path if not present
let cabal_path = $"($nu.home-path)/.cabal/bin"
if not ($env.PATH | any {|p| $p == $cabal_path }) {
    load-env { PATH: ($env.PATH | append $cabal_path) }
}

# Set ghcup path if not present
let ghcup_path = "/home/s/.ghcup/bin"
if not ($env.PATH | any {|p| $p == $ghcup_path }) {
    load-env { PATH: ($env.PATH | append $ghcup_path) }
}

# Always prepend these
load-env {
    PATH: ($env.PATH
        | prepend "/home/dm/Public"
        | prepend "/home/dm/.local/bin"
    )
    SPARK_HOME: "/opt/spark"
    COMPOSE_BAKE: true
}

# Append SPARK_HOME/bin if not present
let spark_bin = $"($env.SPARK_HOME)/bin"
if not ($env.PATH | any {|p| $p == $spark_bin }) {
    load-env { PATH: ($env.PATH | append $spark_bin) }
}

# Ensure Starship cache file exists
let starship_path = "~/.cache/starship.nu" | path expand
if not ($starship_path | path exists) {
    starship init nu | save --raw $starship_path
}

# Ensure Zoxide cache file exists
let zoxide_path = "~/.cache/zoxide.nu" | path expand
if not ($zoxide_path | path exists) {
    zoxide init nushell | save --raw $zoxide_path
}
