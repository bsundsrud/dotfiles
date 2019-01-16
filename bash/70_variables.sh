# check for $HOME/bin in the path before adding it
if echo "$PATH" | grep -qv "$HOME/bin"; then
    export PATH="$HOME/bin:$PATH"
fi

export EDITOR="em"
