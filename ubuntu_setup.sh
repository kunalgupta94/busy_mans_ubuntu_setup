#!/bin/bash

clear

# Applications constants
: ${GIT=1}
: ${NODE=2}
: ${CODE=3}
: ${CHROME=4}
: ${FIREFOXDE=5}


create_checklist () {
	local -n options
    options=$2
	cmd=(dialog --separate-output --checklist $1 22 76 16)
	return $("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) 
}


# Applicatioon checklist

applications_message="Select applications you want to install:"
options=($GIT "Git" ON
$NODE "Node" ON
$CODE "VS Code" ON
$CHROME "Google Chrome" off
$FIREFOXDE "Firefox Developer Edition" ON)

create_checklist "$applications_message" "${options[@]}"
choices=$?

# cmd=(dialog --separate-output --checklist "Select applications you want to install:" 22 76 16)

# choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

# echo -e "Following applications will be installed and configured:\n - Git\n - Node\n - Slack\n - VS Code\n - Linux workspaces setup\n - Unity Themes\n\n"
# dialog --backtitle "Busy Man's ubuntu Setup script" \
# --title "Select applications to install" --clear \
# --checklist 'Select applications you want to install' 40 120 10 \
# "Git"	"" ON \
# "Node"	"" ON \
# "VS Code"	"" ON \
# "Google Chrome"	"" off \
# "Firefox Developer Edition"	"" ON 2> $tmp_file

# return_value=$?

read -p "Press enter to continue [ENTER]" isContinue
echo "${choices}"
tmp_file=$(tempfile 2>/dev/null) || tmp_file=/tmp/test$$
if [[ $isContinue != "" ]]; then
	exit
fi

echo -e "\nFor simplicity sake, please use indiviual users for a specific Git configuration. For Ex: User Company-A for for git configuration for Company-A\n*******\n"
echo -e "Provide a few information before we begin the setup"
read -p "Email (For configuring Git): " gitEmail
read -p "Name (For configuring Git): "  gitName
read -p "Enter git Access token: " gitAccessToken
echo -e "Enter browser you want to install\nChrome (c)\nFirefox Developer Edition (f)"
read -p "(f/ c/ b[both]/ s[skip]): " browser

sshKey=''

setup_git () {
	if [[ -d ~\.ssh\id_ed25519.pub ]]; then
		addedKey=`cat ~\.ssh\id_ed25519.pub`
		echo "git SSH is already setup with key ${addedKey}."
		sshKey=`cat ~/.ssh/id_ed25519.pub`
		return
	fi
	if [[ $gitEmail != "" ]]; then
		echo -e "\n\n"
		read -p "git SSH will be setup for email ${gitEmail} at ~\.ssh\id_ed25519.pub. Press [c] key to change email" -t 10 keyPressed
		if [[ keyPressed == 'c' ]]; then
			read -p "Re-enter email for git setup" gitEmail
		fi
		git config --global user.email "${gitEmail}"
		git config --global user.name "${gitName}"
		echo -e "\n\n\n" | ssh-keygen -t ed25519 -C "${gitEmail}"
		git config --global credential.helper store
		gitCredentialEmail=`echo "$gitEmail" | sed -r 's/[@]+/%401800/g'`
		echo "https://${gitCredentialEmail}:${gitAccessToken}@gitlab.com" > ~/.git-credentials
	fi
	sshKey=`cat ~/.ssh/id_ed25519.pub`
}

install_browser () {
	if [[ $1 == "s" || $1 == "S" ]]; then
		return
	fi
	if [[ $1 == "c" || $1 == "C" || $1 == "b" || $1 == "B" ]]; then
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
		echo -e "\nSuccessfully Installed Google Chrome"
	fi
	if [[ $1 == "f" || $1 == "F" || $1 == "b" || $1 == "B"  ]]; then
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
		Terminal=false"Select applications you want to install:"
		Type=Application
		Categories=Network;WebBrowser;Favorite;
		MimeType=text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp; X-Ayatana-Desktop-Shortcuts=NewWindow;NewIncognitos;
		_EOT_
		echo "Firefox Developer Edition Successfully Installed"
	else
		echo "Entered wrong option. Exiting"
	fi
}

setup_workspaces () {
	gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 2
	gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 2
	gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['<Control><Shift><Alt>Up']"
	gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['<Control><Shift><Alt>Down']"
	gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Control><Shift><Alt>Left']"
	gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Control><Shift><Alt>Right']"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Control><Alt>Up']"
	gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Control><	echo "$1"
	echo "$2"Alt>Down']"
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
	themeIds=("ankitcode.firefly" "marqu3s.aurora-x" "Equinusocio.vsc-material-theme")
	themeNames=("FireFly" "Aurora X" "Material Theme Darker High Contrast")
	settingLocation="$HOME/.config/Code/User/settings.json"

	echo "Select theme for VS code"
	for i in ${!themeNames[@]}
	do
		echo "${i} ${themeNames[$i]}" 
	done
	read userInput

	code="\"workbench.colorTheme\": \"${themeNames[$userInput]}\""
	echo "${code}"
	echo "Installing ${themeNames[${userInput}]}"
	code --install-extension ${themeIds[$userInput]}

	if [[ `cat $settingLocation` != *{* || `cat $settingLocation` != *}* ]]; then
		echo -e "{\n${code}\n}" >> $settingLocation
	else
		sed -i "s/\"workbench.colorTheme.*/${code}/g" $settingLocation
	fi
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
	if [[ `gsettings get org.gnome.desktop.interface gtk-theme` == "Ant-Dracula" ]]; then
		echo "Ant-Dracula Theme already Installed"
		return
	fi
	if [[ -d ~/.themes/Ant-Dracula ]]; then
		gsettings set org.gnome.desktop.interface gtk-theme "Ant-Dracula"
		return
	else
		git clone https://github.com/EliverLara/Ant-Dracula.git
		wait
		if [[ -d ~/.themes ]]; then
			mv Ant-Dracula ~/.themes
		else
			mkdir ~/.themes
			mv Ant-Dracula ~/.themes
		fi
		rm -rf Ant-Dracula
		gsettings set org.gnome.desktop.interface gtk-theme "Ant-Dracula"
		return
	fi
}

sudo apt install curl

setup_git

install_git
install_browser $browser
install_slack
install_code
install_node
install_theme
setup_workspaces
echo -e "Please update SSH key in. SSH key:\n${sshKey}"