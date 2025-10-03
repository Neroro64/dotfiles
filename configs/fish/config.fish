source /usr/share/cachyos-fish-config/cachyos-config.fish


# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
# Environment Variables

set -gx EDITOR nvim
set -gx VISUAL $EDITOR

# Mojo config
set -gx LD_LIBRARY_PATH ~/.local/lib/mojo

# Hydrop config
set -gx fish_prompt_pwd_dir_length 3
set hydro_color_pwd $fish_color_command
set hydro_color_git $fish_color_command
set hydro_color_error $fish_color_error
set hydro_color_prompt --dim $fish_color_command
set hydro_color_duration --dim $fish_color_command

# Set fish theme
fish_config theme choose "Tomorrow Night"

# Enable Vi mode
fish_vi_key_bindings

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias lg='lazygit'
alias rng='ranger'

# Add local bin to PATH
fish_add_path ~/.local/bin
fish_add_path ~/.bun/bin
fish_add_path ~/.modular/bin
fish_add_path /opt/cuda/bin

function ex
    set depth $argv[1]
    if test -z "$depth"
        set depth 1
    end
    command exa -T -L"$depth" --git -l
end

function enable_3090
    sudo nvidia-smi drain -p 0000:0c:00.0 -m 0
    sudo nvidia-smi -i 1 -pm 1
end

function disable_3090
    nvidia-smi -i 1 -pm 1
    nvidia-smi drain -p 0000:0c:00.0 -m 1
end

# Find process using port
function port
    if test (count $argv) = 1
        lsof -i :$argv[1]
    else
        echo "Usage: port <port_number>"
    end
end

function weather
    curl https://wttr.in
end

fish_add_path /home/nuoc/.pixi/bin
