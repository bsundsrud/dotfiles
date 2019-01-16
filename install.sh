#!/bin/bash
dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
bashrc_file="$1"

if [ -z "$bashrc_file" ]; then
    bashrc_file="$HOME/.bashrc"
fi

payload="
DOTFILES_DIR="$dotfiles_dir"
. \$DOTFILES_DIR/bashrc_includes
"

bashrc_installed="0"
if grep -q "^### dotfiles start ###" "$bashrc_file"; then
    bashrc_installed="1"
fi

replace() {
    tmpfile="$(mktemp)"
    newbashrc="$(mktemp)"
    echo "$payload" > "$tmpfile"
    
    PAYLOAD="$tmpfile" awk '
    BEGIN       {p=1}
    /^### dotfiles start ###/   {print;system("cat $PAYLOAD");p=0}
    /^### dotfiles end ###/     {p=1}
    p' "$bashrc_file" > "$newbashrc"
    cat "$newbashrc" > "$bashrc_file"
    rm "$newbashrc"
    rm "$tmpfile"
}

if [ "$bashrc_installed" -eq 1 ]; then
    echo "Reinstalling bashrc includes in '$bashrc_file'..."
    replace
else
    echo "Installing bashrc includes in '$bashrc_file'..."
    echo "### dotfiles start ###" >> "$bashrc_file"
    echo "$payload" >> "$bashrc_file"
    echo "### dotfiles end ###" >> "$bashrc_file"
fi

bash "$dotfiles_dir/gitconfig"

echo "Installing bin dir..."
mkdir -p "$HOME/bin"
cp $dotfiles_dir/bin/* "$HOME/bin"
