#!/bin/bash

clear

install_browser () {
	if [[ $1 == "c" || $1 == "C" ]]; then
		chromePath=`which google-chrome`
		if [[ $chromePath != "" ]]; then
			version=`google-chrome --version`
			echo -e "Google Chrome ${version}is already installed"
			return
		fi
		echo -e "\n\033[1mDownloading Google Chrome"
		curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		wait
		echo -e "\nInstalling Google Chrome"
		sudo apt install ./google-chrome-stable_current_amd64.deb
		rm -rf google-chrome-stable_current_amd64.deb
		echo -e "\nSuccessfully Installed Google Chrome"
	fi
	if [[ $1 == "f" || $1 == "F" ]]; then
		if [[ -d /opt/firefox ]]; then
			echo "Firefox Developer Edition is already installed"
			return
		fi
		echo "Downloading Firefox Developer Edition"
		curl -O https://download-installer.cdn.mozilla.net/pub/devedition/releases/74.0b7/linux-x86_64/en-US/firefox-74.0b7.tar.bz2
		wait
		echo "Extracting Tar file"
		sudo tar xjf firefox*.tar.bz2
		echo "Removing tar folder"
		sudo rm -rf firefox*.tar.bz2
		echo "Configuring Firefox Developer Edition"
		sudo mv firefox /opt
		sudo chown -R $USER /opt/firefox
		sudo echo "export PATH=/opt/firefox/firefox:$PATH" >> ~/.bashrc
		cat > ~/.local/share/applications/firefoxDeveloperEdition.desktop <<-_EOT_
		[Desktop Entry]
		Encoding=UTF-8
		Name=Firefox Developer Edition
		Exec=/opt/firefox/firefox
		Icon=/opt/firefox/browser/chrome/icons/default/default128.png
		Terminal=false
		Type=Application
		Categories=Network;WebBrowser;Favorite;
		MimeType=text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp; X-Ayatana-Desktop-Shortcuts=NewWindow;NewIncognitos;
		_EOT_
		echo "Firefox Developer Edition Successfully Installed"
	else
		echo "Entered wrong option. Exiting"
	fi
}

install_slack () {
	isSnap=`which snap`
	if [[ $isSnap != "" ]]; then
		sudo snap install slack --classic
	else
		sudo apt install snap
		sudo snap install slack --classic
	fi
}

install_git () {
	isGit=`git --version`
	if [[ $isGit != "" ]]; then
		echo "Git ${isGit} is already installed"
		return
	fi
	sudo apt install git -y
}

install_code () {
	sudo snap install code --classic
}

install_node () {
	checkNode=`node --version`
	checkNpm=`npm --version`
	if [[ $checkNode != "" && $checkNpm != "" ]]; then
		echo "Node ${checkNode} and npm ${checkNpm} is already installed"
		return
	fi
	echo "Downloading NV to install node"
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
	wait
	echo "\nExporting variables to .bashrc"
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
	isInstalled=`command -v nvm`
	if [[ $isInstalled == "" ]]; then
		echo "Error Occured while Installing NVM"
		return
	fi
	echo "Installing Node"
	nvm install node
}

install_theme () {
	curl -O https://dllb2.pling.com/api/files/download/j/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjE1ODE2MTgxMzkiLCJ1IjpudWxsLCJsdCI6ImRvd25sb2FkIiwicyI6ImYwNTY5Njc0M2QwNTFhZmI1NDcxZmY1NjEzN2Q0OWE1ZDM3ZGM3YzUwY2FjMGNhYjhmMzY3ODBlMDEwZTYwYzM2OTZmZTk4MTU5MDI4OTBlMzI1NTQxYmY5M2VlOTQ5OThhZjkxMjY1M2NlYzc1MjUxZDk1YzllMjQ5M2U2YjAwIiwidCI6MTU4MjYzOTc4MCwic3RmcCI6bnVsbCwic3RpcCI6bnVsbH0.__1EiIXEtlp-LM_n3-_crUQqoyTgdgutIHhX8iwMY5I/Ant-Dracula.tar
	wait
	tar -xvf Ant-Dracula.tar
	rm -rf Ant-Dracula.tar
	if [[ -d ~/.themes ]]; then
		mv Ant-Dracula ~/.themes
	else
		mkdir ~/.themes
		mv Ant-Dracula ~/.themes
	fi
	sudo apt install unity-tweak-tool
}


echo "Ubuntu Setup script. This shell script will install basic developer utitlities required"

sudo apt install curl

echo -e  "\n\nSelect a broweser"
echo -e "Chrome\nFirefox Developer Edition"
read browser

install_git
install_browser $browser
install_slack
install_code
install_node
install_theme
