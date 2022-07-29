#!/bin/zsh

BOLD=$(tput bold)
UNDERLINE=$(tput smul)
ITALIC=$(tput sitm)
RESET="\033[0m"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
MAGENTA="\e[1;35m"
CYAN="\e[1;36m"
VERSION="1.8.0"

function 42-wizzard-clean() {
	# displaying available storage before cleaning
	STORAGE_AVAILABLE=$(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B')
	printf "• Free storage before cleaning:$GREEN $STORAGE_AVAILABLE $RESET \n"
	# start loading animation
	start_loading_animation "${cleaning[@]}" 2> /dev/null
	# cleaning
	/bin/rm -rf $HOME/.Trash/* > /dev/null 2>&1
	/bin/rm -rf $HOME/Library/*.42* > /dev/null 2>&1
	/bin/rm -rf $HOME/*.42* > /dev/null 2>&1
	/bin/chmod -R 777 $HOME/Library/Caches/Homebrew > /dev/null 2>&1
	/bin/rm -rf $HOME/Library/Caches/* > /dev/null 2>&1
	/bin/rm -rf $HOME/Library/Application\ Support/Caches/* > /dev/null 2>&1
	/bin/rm -rf $HOME/Library/Application\ Support/Slack/Service\ Worker/CacheStorage/* > /dev/null 2>&1
	/bin/rm -rf $HOME/Library/Application\ Support/Code/User/workspaceStorage/* > /dev/null 2>&1
	/bin/rm -rf $HOME/Library/Application\ Support/discord/Cache/* > /dev/null 2>&1
	/bin/rm -rf $HOME/Library/Application\ Support/discord/Code\ Cache/js* > /dev/null 2>&1
	/bin/rm -rf $HOME/Library/Application\ Support/Google/Chrome/Default/Service\ Worker/CacheStorage/* > /dev/null 2>&1
	/bin/rm -rf $HOME/Library/Application\ Support/Google/Chrome/Default/Application\ Cache/* > /dev/null 2>&1
	# stop loading animation
	stop_loading_animation
	# displaying available storage after cleaning
	STORAGE_AVAILABLE=$(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B')
	printf "• Free storage after cleaning:$GREEN $STORAGE_AVAILABLE $RESET \n"
}

function 42-wizzard-storage() {
	# displaying total storage
	printf "$BLUE• Total storage: $(df -h | grep "$USER" | awk '{print($2)}' | tr 'i' 'B') $RESET \n"
	# displaying used storage
	printf "$RED• Used storage:  $(df -h | grep "$USER" | awk '{print($3)}' | tr 'i' 'B') $RESET \n"
	# displaying available storage
	printf "$GREEN• Available storage:  $(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B') $RESET \n"
}

function 42-wizzard-brew() {
	# removing brew if it exists
	rm -rf $HOME/.brew > /dev/null 2>&1
	# start loading animation
	start_loading_animation "${cloning[@]}" 2> /dev/null
	git clone --depth=1 https://github.com/Homebrew/brew $HOME/.brew > /dev/null 2>&1
	# stop loading animation
	stop_loading_animation
	# start loading animation
	start_loading_animation "${metro[@]}" 2> /dev/null
	# configuring brew
	cat > $HOME/.brewconfig.zsh <<EOL
	# Load Homebrew config script
	export PATH=\$HOME/.brew/bin:\$PATH
	export HOMEBREW_CACHE=/tmp/\$USER/Homebrew/Caches
	export HOMEBREW_TEMP=/tmp/\$USER/Homebrew/Temp
	mkdir -p \$HOMEBREW_CACHE
	mkdir -p \$HOMEBREW_TEMP
	if df -T autofs,nfs \$HOME 1>/dev/null
		then
		HOMEBREW_LOCKS_TARGET=/tmp/\$USER/Homebrew/Locks
		HOMEBREW_LOCKS_FOLDER=\$HOME/.brew/var/homebrew
		mkdir -p \$HOMEBREW_LOCKS_TARGET
		mkdir -p \$HOMEBREW_LOCKS_FOLDER
		if ! [[ -L \$HOMEBREW_LOCKS_FOLDER && -d \$HOMEBREW_LOCKS_FOLDER ]]
			then
			echo "Creating symlink for Locks folder"
			rm -rf \$HOMEBREW_LOCKS_FOLDER
			ln -s \$HOMEBREW_LOCKS_TARGET \$HOMEBREW_LOCKS_FOLDER
		fi
	fi
EOL
	if ! grep -q "# Load Homebrew config script" $HOME/.zshrc
		then
		cat >> $HOME/.zshrc <<EOL
		source \$HOME/.brewconfig.zsh
EOL
	fi
	# stop loading animation
	stop_loading_animation
	# start loading animation
	start_loading_animation "${metro[@]}" 2> /dev/null
	source $HOME/.brewconfig.zsh > /dev/null 2>&1
	rehash > /dev/null 2>&1
	brew update > /dev/null 2>&1
	stop_loading_animation
	# print brew version
	BREW_VERSION=$(brew --version | head -n 1 | awk '{print($2)}')
	printf "Homebrew $GREEN v$BREW_VERSION $RESET installed! \n"
}

function 42-wizzard-docker() {
	printf "Chose a destination folder to install docker $GREEN hit enter to use goinfre(recommended)$RESET \n"
	# read docker destination folder
	read -e docker_destination
	# if user didn't choose a folder, use goinfre
	if [ -z "$docker_destination" ]
		then
		docker_destination="/goinfre/$USER/docker"
	fi
	# uninstalling docker if it exists
	brew uninstall -f docker docker-compose docker-machine > /dev/null 2>&1
	# check if docker is installed
	if [ ! -d "/Applications/Docker.app" ] && [ ! -d "~/Applications/Docker.app" ]; then
		printf "$YELLOW Docker is not installed $RESET \n"
		printf "Please install docker trough $BLUE Managed Software Center $RESET then hit enter to continue \n"
		open -a "Managed Software Center"
		start_loading_animation "${waiting[@]}" 2> /dev/null
		read -n 1
		stop_loading_animation
	fi
	# killing all docker processes
	pkill Docker 2> /dev/null
	# unlinking docker from /Applications
	unlink ~/Library/Containers/com.docker.docker > /dev/null 2>&1
	unlink ~/Library/Containers/com.docker.helper > /dev/null 2>&1
	unlink ~/.docker > /dev/null 2>&1
	unlink ~/Library/Containers/com.docker.docker > /dev/null 2>&1
	unlink ~/Library/Containers/com.docker.helper > /dev/null 2>&1
	unlink ~/.docker > /dev/null 2>&1
	# removing docker old folders
	/bin/rm -rf ~/Library/Containers/com.docker.{docker,helper} ~/.docker > /dev/null 2>&1
	# creating docker destination folder
	mkdir -p "$docker_destination"/{com.docker.{docker,helper},.docker} > /dev/null 2>&1
	# linking docker to destination folder
	ln -sf "$docker_destination"/com.docker.docker ~/Library/Containers/com.docker.docker > /dev/null 2>&1
	ln -sf "$docker_destination"/com.docker.helper ~/Library/Containers/com.docker.helper > /dev/null 2>&1
	ln -sf "$docker_destination"/.docker ~/.docker > /dev/null 2>&1
	printf "Docker installed in $GREEN $docker_destination $RESET \n"
	# opening docker app
	open -g -a Docker
}

function 42-wizzard-code() {
	# appending an alias to zshrc
	echo 'code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}' >> $HOME/.zshrc
	# source zshrc
	source $HOME/.zshrc
	printf $GREEN "You can use the code command now!" $RESET
}

function 42-wizzard-ssh() {
	# starting loading animation
	start_loading_animation "${loading[@]}"
	# removing old keys if it exists
	/bin/rm -rf $HOME/.ssh
	# creating new keys
	ssh-keygen -C "" -f ~/.ssh/id_rsa -N "" > /dev/null 2>&1
	# copying public key to clipboard
	cat ~/.ssh/id_rsa.pub | awk '{print($2)}' | pbcopy
	sleep 2
	# stopping loading animation
	stop_loading_animation
	printf "$GREEN SSH key copied to clipboard $RESET \n"
	printf "$BLUE https://profile.intra.42.fr/gitlab_users $RESET"
	sleep 1
	# opening gitlab profile to add ssh key
	open https://profile.intra.42.fr/gitlab_users
}

function 42-wizzard-nvm() {
	# starting loading animation
	start_loading_animation "${installing[@]}" 2> /dev/null
	# installing nvm
	curl -fsSL https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | zsh > /dev/null 2>&1
	# source nvm
	source $HOME/.nvm/nvm.sh > /dev/null 2>&1
	# stopping loading animation
	stop_loading_animation
	# print nvm version
	NVM_VERSION=$(nvm --version)
	printf "nvm $GREEN v$NVM_VERSION $RESET installed! \n"
}

function 42_node() {
	# checking if nvm is installed
	if which nvm > /dev/null
		then
		# starting loading animation
		start_loading_animation "${installing[@]}" 2> /dev/null
		# installing node
		nvm install node
		# stopping loading animation
		stop_loading_animation
	else
		printf "$RED nvm is not installed $RESET \n"
		printf "Installing nvm first"
		# installing nvm
		42-wizzard-nvm
		# starting loading animation
		start_loading_animation "${installing[@]}" 2> /dev/null
		# installing node
		nvm install node > /dev/null 2>&1
		# stopping loading animation
		stop_loading_animation
		# print node + npm versions
		NODE_VERSION=$(node --version)
		NPM_VERSION=$(npm --version)
		printf "node $GREEN v$NODE_VERSION $RESET installed! \n"
		printf "npm $GREEN v$NPM_VERSION $RESET installed! \n"
	fi
}

function 42-wizzard-oh-my-zsh() {
	# checking if oh-my-zsh is installed
	if [ ! -d "$HOME/.oh-my-zsh" ]
		then
		# starting loading animation
		start_loading_animation "${installing[@]}" 2> /dev/null
		# installing oh-my-zsh
		sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2>&1
		# source zshrc
		source $HOME/.zshrc > /dev/null 2>&1
		# stopping loading animation
		stop_loading_animation
		# print oh-my-zsh version
		printf "$GREEN Oh My Zsh $RESET installed! \n"
	fi
}

function 42-wizzard-reset() {
	# check for user input
	printf "$RED Are you sure you want to reset your session? $RESET (yes/no)\n"
	read -r answer
	# if user input is yes
	if [ "$answer" = "yes" ]
		then
		# resetting session
		touch $HOME/.reset
		touch $HOME/.reset_Library
		# logging out
		osascript -e 'tell application "loginwindow" to  «event aevtrlgo»'
	else
		# aborting reset
		printf "$YELLOW Aborting \n"
	fi
}

function 42-wizzard-ds-store () {
	# check for user input
	printf "$YELLOW Are you sure you want to remove .DS_Store files? $RESET (yes/no) \n"
	read -r answer
	# if user input is yes
	if [ "$answer" = "yes" ]
		then
		cd $HOME
		# starting loading animation
		start_loading_animation "${cleaning[@]}" 2> /dev/null
		# removing .DS_Store files
		find . -name .DS_Store -delete > /dev/null 2>&1
		# stopping loading animation
		stop_loading_animation
		cd - > /dev/null 2>&1
	else
		# aborting delete
		printf "$YELLOW Aborting \n"
	fi
	# check for user input
	printf "$YELLOW Are you sure you want to prevent your os from creating .DS_Store files? $RESET (yes/no) \n"
	read -r answer
	# if user input is yes
	if [ "$answer" = "yes" ]
		then
		# preventing os from creating .DS_Store files
		defaults write com.apple.desktopservices DSDontWriteNetworkStores true
	else
		# aborting prevent
		printf "$YELLOW Aborting \n"
	fi
}

function 42-wizzard-help() {
	printf "42-wizzard$GREEN v$VERSION $RESET \n"
	# big thanks to Oummixa
	if [ "$USER" = "oel-yous" ];
		then
		printf "hey Oummixa!! \n"
	fi
	# print help
	printf "$GREEN	-clean -c $RESET				Clean your session. \n"
	printf "$GREEN	-storage -s $RESET				Show your storage. \n"
	printf "$GREEN	-brew $RESET					Install brew. \n"
	printf "$GREEN	-docker $RESET				Install docker. \n"
	printf "$GREEN	-code $RESET					Add code command to your zsh. \n"
	printf "$GREEN	-ssh $RESET					Generate ssh key. \n"
	printf "$GREEN	-nvm $RESET					Install nvm. \n"
	printf "$GREEN	-node $RESET					Install node. \n"
	printf "$GREEN	-oh-my-zsh -omz $RESET			Install oh-my-zsh. \n"
	printf "$GREEN	-ds-store -ds $RESET				Remove .DS_Store files + prevent os from creating them. \n"
	printf "$GREEN	-reset -r $RESET				Reset your session. \n"
	printf "$GREEN	-update -u $RESET				Update your the wizzard. \n"
	printf "$GREEN	-help -h $RESET				Show this help. \n"
}

function 42() {
	# load animation script
	source ~/.42-wizzard-loading.sh
	# capture signals to stop loading animation
	trap stop_loading_animation SIGINT
	set +m
	case $1 in
		-clean|-c) 42-wizzard-clean 2> /dev/null 
		;;
		-storage|-s) 42-wizzard-storage 2> /dev/null
		;;
		-brew) 42-wizzard-brew
		;;
		-docker) 42-wizzard-docker 2> /dev/null
		;;
		-code) 42-wizzard-code
		;;
		-ssh) 42-wizzard-ssh
		;;
		-nvm) 42-wizzard-nvm 2> /dev/null
		;;
		-node) 42_node 2> /dev/null
		;;
		-oh-my-zsh|-omz) 42-wizzard-oh-my-zsh 2> /dev/null
		;;
		-ds-store|-ds) 42-wizzard-ds-store
		;;
		-reset|-r) 42-wizzard-reset
		;;
		-update|-u) sh ~/.42-wizzard-updater.sh
		;;
		-help|-h) 42-wizzard-help
		;;
		*) echo 42: "Unknown command: $1" ; 42-wizzard-help
		;;
	esac
	set -m
}
