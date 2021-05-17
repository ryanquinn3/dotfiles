#! /bin/zsh
set -e

DIR=$(cd `dirname $0` && pwd)

if [ -d ~/.oh-my-zsh ]; then
    echo "Oh my zsh is already installed"
else
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ -n "$(which nvm)" ]; then
	curl -o- https://raw.githusubl busercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
fi


echo "Symlinking dotfiles..."
ln -sf $DIR/.functions ~/.functions
ln -sf $DIR/.zshrc ~/.zshrc
ln -sf $DIR/oh-my-zsh.sh ~/.oh-my-zsh/oh-my-zsh.sh


echo "Configuring shell..."
source ~/.zshrc
echo "Done."
