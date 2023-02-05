#! /bin/zsh
set -e

DIR=$(cd `dirname $0` && pwd)

function configure_screenshot_storage(){
	# Setup the screenshots directory and have the OS store all screenshots there
	[ ! -d ~/screenshots ] && mkdir ~/screenshots
	defaults write com.apple.screencapture location ~/screenshots
	defaults write com.apple.screencapture "show-thumbnail" -bool "false" 
	killall SystemUIServer
}

function configure_dock_settings(){
	defaults write com.apple.dock "autohide" -bool "true"
	defaults write com.apple.dock "orientation" -string "left"
	killall Dock
}

function configure_finder() {
	defaults write com.apple.finder "ShowPathbar" -bool "true" && killall Finder
}

if [ -d ~/.oh-my-zsh ]; then
    echo "Oh my zsh is already installed"
else
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ -n "$(which nvm)" ]; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
fi


echo "Symlinking dotfiles..."
ln -sf $DIR/.functions ~/.functions
ln -sf $DIR/.zshrc ~/.zshrc
ln -sf $DIR/oh-my-zsh.sh ~/.oh-my-zsh/oh-my-zsh.sh

echo -ne "Updating MacOS UI config...\033[0K\r“"
configure_screenshot_storage
configure_dock_settings
configure_finder
echo -e "Updating MacOS UI config... Done“"


echo "Configuring shell..."
source ~/.zshrc
echo "Done."

echo "Installing node..."
nvm install --lts