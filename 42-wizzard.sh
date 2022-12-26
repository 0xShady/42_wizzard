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
WIZZARD_VERSION="2.5.0"
ANIMATION_RATE=0.3
declare -a ACTIVE_LOADING

# loadig animation arrays
classic=('-' "\\" '|' '/')

cloning=( 'cloning   ' 'cloning.  ' 'cloning.. ' 'cloning...')

loading=('loading   ' 'loading.  ' 'loading.. ' 'loading...')

waiting=('waiting   ' 'waiting.  ' 'waiting.. ' 'waiting...')

installing=('installing   ' 'installing.  ' 'installing.. ' 'installing...')

building=('building   ' 'building.  ' 'building.. ' 'building...')

configuring=('configuring   ' 'configuring.  ' 'configuring.. ' 'configuring...')

cleaning=('cleaning   ' 'cleaning.  ' 'cleaning.. ' 'cleaning...')
metro=(	'[                        ]'
		'[=                       ]'
		'[==                      ]'
		'[===                     ]'
		'[====                    ]'
		'[=====                   ]'
		'[======                  ]'
		'[=======                 ]'
		'[========                ]'
		'[=========               ]'
		'[==========              ]'
		'[===========             ]'
		'[============            ]'
		'[ ============           ]'
		'[  ============          ]'
		'[   ============         ]'
		'[    ============        ]'
		'[     ============       ]'
		'[      ============      ]'
		'[       ============     ]'
		'[        ============    ]'
		'[         ============   ]'
		'[          ============  ]'
		'[           ============ ]'
		'[            ============]'
		'[             ===========]'
		'[              ==========]'
		'[               =========]'
		'[                ========]'
		'[                 =======]'
		'[                  ======]'
		'[                   =====]'
		'[                    ====]'
		'[                     ===]'
		'[                      ==]'
		'[                       =]' )


function play_loading_animation_loop() {
	while true ; do
		for FRAME in "${ACTIVE_LOADING[@]}" ; do
			printf "\r%s" "${FRAME}"
			sleep $ANIMATION_RATE
		done
	done
}

function start_loading_animation() {
	ACTIVE_LOADING=( "${@}" )
	# Hide the terminal cursor
	tput civis
	# disable terminal monitoring
	set +m
	# run loading loop on sub-shell
	play_loading_animation_loop &
	# get loading loop pid
	LOADING_LOOP_PID="${!}"
}

function stop_loading_animation() {
	# kill background process
	kill "${LOADING_LOOP_PID}" 2> /dev/null
	printf "\n"
	# Restore the terminal cursor
	tput cnorm
	# enable terminal monitoring back
	set -m
}

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
	sleep 2
	# stop loading animation
	stop_loading_animation
	# displaying available storage after cleaning
	STORAGE_AVAILABLE=$(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B')
	printf "• Free storage after cleaning:$GREEN $STORAGE_AVAILABLE $RESET \n"
}

function 42-wizzard-storage() {
	# displaying total storage
	echo "• Total storage: $BLUE $(df -h | grep "$USER" | awk '{print($2)}' | tr 'i' 'B') $RESET"
	# displaying used storage
	echo "• Used storage: $RED $(df -h | grep "$USER" | awk '{print($3)}' | tr 'i' 'B') $RESET"
	# displaying available storage
	echo "• Available storage: $GREEN $(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B') $RESET"
	# displaying heavy files
	cd
	echo "$YELLOW Heavy files: $RESET"
	find . -size +50M -exec ls -lh {} \; 2> /dev/null | sort -k 5 -nr | awk '{print $9  $10  " " "\033[32m" $5 "\033[0m" }' | column -t
	cd - > /dev/null 2>&1
}

function 42-wizzard-brew() {
	# check if brew is installed
	if which brew > /dev/null 2>&1 
		then
		BREW_VERSION=$(brew --version | head -n 1 | awk '{print($2)}' | cut -d'-' -f1)
		echo "Brew is $GREEN $BREW_VERSION $RESET already installed"
		echo "Do you want to reinstall it? (yes/no)"
		read -r ANSWER
		if [ "$ANSWER" != "yes" ]
		then
			exit 0
		fi
	fi
	echo "installing brew"
	# start loading animation
	start_loading_animation "${metro[@]}" 2> /dev/null
	cd ~/goinfre
	# remove old brew
	rm -rf $HOME/.brew > /dev/null 2>&1
	rm -rf $HOME/goinfre/homebrew > /dev/null 2>&1
	# clean .zshrc
	sed -n '/brew/!p' ~/.zshrc > .tmp && mv .tmp ~/.zshrc
	# curl brew
	mkdir homebrew && curl -sL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew > /dev/null 2>&1
	# add brew to .zshrc
	echo "export PATH=~/goinfre/homebrew/bin:$PATH" >> $HOME/.zshrc
	# source .zshrc
	source $HOME/.zshrc > /dev/null 2>&1
	# update brew
	brew update > /dev/null 2>&1
	# stop loading animation
	stop_loading_animation
	# brew version
	BREW_VERSION=$(brew --version | head -n 1 | awk '{print($2)}' | cut -d'-' -f1)
	printf "Homebrew $GREEN v$BREW_VERSION $RESET installed! \n"
	cd - > /dev/null 2>&1
}

function 42-wizzard-docker() {
	echo "Chose a destination folder to install docker $GREEN hit enter to use goinfre(recommended)$RESET \n"
	# read docker destination folder
	read -e docker_destination
	# if user didn't choose a folder, use goinfre
	if [ -z "$docker_destination" ]
		then
		docker_destination="/goinfre/$USER/docker"
	fi
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
	echo "$GREEN SSH key copied to clipboard $RESET \n"
	echo "$BLUE https://profile.intra.42.fr/gitlab_users $RESET"
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
	echo "nvm $GREEN v$NVM_VERSION $RESET installed! \n"
}

function  42-wizzard-node() {
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
		echo "$RED nvm is not installed $RESET \n"
		echo "Installing nvm first"
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
		echo "node $GREEN v$NODE_VERSION $RESET installed! \n"
		echo "npm $GREEN v$NPM_VERSION $RESET installed! \n"
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
	read -r ANSWER
	# if user input is yes
	if [ "$ANSWER" = "yes" ]
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
	read -r ANSWER
	# if user input is yes
	if [ "$ANSWER" = "yes" ]
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
	read -r ANSWER
	# if user input is yes
	if [ "$ANSWER" = "yes" ]
		then
		# preventing os from creating .DS_Store files
		defaults write com.apple.desktopservices DSDontWriteNetworkStores true
	else
		# aborting prevent
		printf "$YELLOW Aborting \n"
	fi
}

function 42-wizzard-pip() {
	#starting loading animation
	start_loading_animation "${installing[@]}" 2> /dev/null
	# curling pip
	curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py > /dev/null 2>&1
	# bulding pip
	python3 get-pip.py > /dev/null 2>&1
	rm get-pip.py > /dev/null 2>&1
	# make alias for pip
	echo "alias pip='pip3'" >> $HOME/.zshrc
	# source zshrc
	source $HOME/.zshrc > /dev/null 2>&1
	# stopping loading animation
	stop_loading_animation
	# print pip version
	if which pip > /dev/null
		then
		printf "$GREEN Pip $RESET installed! \n"
	else
		printf "$RED Pip $RESET not installed! \n"
	fi
}

function 42-wizzard-help() {
	echo "42-wizzard$GREEN v$WIZZARD_VERSION $RESET"
	# big thanks to Oummixa
	if [ "$USER" = "oel-yous" ];
		then
		echo "hey Oummixa!!"
	fi
	# print help
	echo "$GREEN	-clean -c $RESET				Clean your session."
	echo "$GREEN	-storage -s $RESET				Show your storage and heavy files."
	echo "$GREEN	-code $RESET					Add code command to your zsh."
	echo "$GREEN	-ssh $RESET					Generate a new ssh key and copying it to your clipboard."
	echo "$GREEN	-brew $RESET					Install brew."
	echo "$GREEN	-docker $RESET				Install docker."
	echo "$GREEN	-nvm $RESET					Install nvm."
	echo "$GREEN	-node $RESET					Install node."
	echo "$GREEN	-pip $RESET					Install pip."
	echo "$GREEN	-oh-my-zsh -omz $RESET			Install oh-my-zsh."
	echo "$GREEN	-ds-store -ds $RESET				Remove .DS_Store files, prevent os from creating them."
	echo "$GREEN	-reset -r $RESET				Reset your session."
	echo "$GREEN	-update -u $RESET				Update your the wizzard."
	echo "$GREEN	-help -h $RESET				Show this help."
}

function 42() {
	trap stop_loading_animation SIGINT
	case $1 in
		-clean|-c) 42-wizzard-clean 2> /dev/null
		;;
		-storage|-s) 42-wizzard-storage
		;;
		-reset|-r) 42-wizzard-reset
		;;
		-update|-u) sh ~/.42-wizzard-updater.sh > /dev/null 2>&1
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
		-pip) 42-wizzard-pip 2> /dev/null
		;;
		-node) 42-wizzard-node 2> /dev/null
		;;
		-oh-my-zsh|-omz) 42-wizzard-oh-my-zsh 2> /dev/null
		;;
		-ds-store|-ds) 42-wizzard-ds-store
		;;
		-help|-h) 42-wizzard-help
		;;
		*) echo 42: "Unknown flag: $1" ; echo "Usage: 42 -flag"; 42-wizzard-help
		;;
	esac
}
