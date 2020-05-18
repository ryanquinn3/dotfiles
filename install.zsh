#! /bin/zsh

DIR=$(cd `dirname $0` && pwd)

echo "Symlinking dotfiles..."
ln -sf $DIR/.functions ~/.functions
ln -sf $DIR/.zshrc ~/.zshrc


echo "Configuring shell..."
source ~/.zshrc
echo "Done."
