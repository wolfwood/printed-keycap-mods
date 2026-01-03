#!/usr/bin/env bash
set -e

echo "source $DEVCONTAINER_DIR/on-shell-start.sh" >> ~/.bashrc
echo "source $DEVCONTAINER_DIR/on-shell-start.sh" >> ~/.zshrc

# Enable VS Code shell integration
echo '[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"' >> ~/.bashrc
echo '[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"' >> ~/.zshrc

# Fix git credential helper to use container's gh path instead of host's homebrew path (we might not be allowed to write to ~/.gitconfig though)
if command -v git &> /dev/null; then
    git config --global --unset-all credential.'https://github.com'.helper 2>/dev/null || true
    git config --global --add credential.'https://github.com'.helper '!/usr/bin/gh auth git-credential' || true
    git config --global --unset-all credential.'https://gist.github.com'.helper 2>/dev/null || true
    git config --global --add credential.'https://gist.github.com'.helper '!/usr/bin/gh auth git-credential' || true
fi

# for zsh completions: Add to fpath and enable completions if not already present
if ! grep -q "fpath+=~/.zfunc" ~/.zshrc; then
    echo 'fpath+=~/.zfunc' >> ~/.zshrc
    echo 'autoload -Uz compinit && compinit' >> ~/.zshrc
fi

echo "Ensuring we have the submodules..."
git submodule update --init --recursive

echo "Trying to limit SCAD ram usage..."
mkdir -p ~/.config/OpenSCAD
cp $DEVCONTAINER_DIR/OpenSCAD.conf ~/.config/OpenSCAD

#echo "Doing an initial build..."
#make