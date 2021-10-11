# Increase history size so it lasts a few months.
# Then you can search your shell history with Ctrl+R
# Rest of the history is set with oh-my-zsh defaults:
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh
export HISTSIZE=100000000
export SAVEHIST=$HISTSIZE


# set the language of the system
export LANG=en_US.UTF-8
export LC_ALL=$LANG


# -R for color support
# other options that are sometimes useful:
# -F no paging if it fits on screen
# -X don't reset/clear screen on exit
export LESS='--tabs=4 -FRX'

# Load environment variables from $HOME/.env file.
# Currently it can be any script, and it's up to the discression of the
# user to only use this for exporting environment variables.
set -a
[[ ! -f $HOME/.env ]] || source $HOME/.env
set +a

# Put $HOME/bin on the PATH, so user scripts can be placed there
# and appear on the path automatically.
# Also put $HOME/.local/bin on the path for python
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
