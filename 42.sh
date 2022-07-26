
RESET="\033[0m"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
MAGENTA="\e[1;35m"
CYAN="\e[1;36m"

function 42_clean() {

    STORAGE_AVAILABLE=$(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B')
    echo -e "       • Free storage before cleaning: $STORAGE_AVAILABLE"

    /bin/rm -rf "$HOME"/.Trash/* &>/dev/null
    /bin/rm -rf "$HOME"/Library/*.42* &>/dev/null
    /bin/rm -rf "$HOME"/*.42* &>/dev/null
    /bin/chmod -R 777 "$HOME"/Library/Caches/Homebrew &>/dev/null
    /bin/rm -rf "$HOME"/Library/Caches/* &>/dev/null
    /bin/rm -rf "$HOME"/Library/Application\ Support/Caches/* &>/dev/null
    /bin/rm -rf "$HOME"/Library/Application\ Support/Slack/Service\ Worker/CacheStorage/* &>/dev/null
    /bin/rm -rf "$HOME"/Library/Application\ Support/Code/User/workspaceStorage/* &>/dev/null
    /bin/rm -rf "$HOME"/Library/Application\ Support/discord/Cache/* &>/dev/null
    /bin/rm -rf "$HOME"/Library/Application\ Support/discord/Code\ Cache/js* &>/dev/null
    /bin/rm -rf "$HOME"/Library/Application\ Support/Google/Chrome/Default/Service\ Worker/CacheStorage/* &>/dev/null
    /bin/rm -rf "$HOME"/Library/Application\ Support/Google/Chrome/Default/Application\ Cache/* &>/dev/null

    STORAGE_AVAILABLE=$(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B')
    echo -e "       • Free storage after cleaning: $STORAGE_AVAILABLE"
}

function 42_storage() {

    echo -e "$BLUE   • Total storage: $(df -h | grep "$USER" | awk '{print($2)}' | tr 'i' 'B') $RESET"
    echo -e "$RED   • Used storage:  $(df -h | grep "$USER" | awk '{print($3)}' | tr 'i' 'B') $RESET"
    echo -e "$GREEN   • Available storage:  $(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B') $RESET"
}

function 42_brew() {
    rm -rf $HOME/.brew
    git clone --depth=1 https://github.com/Homebrew/brew $HOME/.brew
    cat > $HOME/.brewconfig.zsh <<EOL
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
    source $HOME/.brewconfig.zsh
    rehash
    brew update
}

function 42_docker() {
    echo -e "Chose a destination folder to install docker $GREEN hit enter to use goinfre(recommended) or enter a path $RESET"
    read -e docker_destination
    if [ -z "$docker_destination" ]
        then
        docker_destination="/goinfre/$USER/docker"
    fi
    brew uninstall -f docker docker-compose docker-machine &>/dev/null
    pkill Docker
    unlink ~/Library/Containers/com.docker.docker &>/dev/null
    unlink ~/Library/Containers/com.docker.helper &>/dev/null
    unlink ~/.docker &>/dev/null
    unlink ~/Library/Containers/com.docker.docker &>/dev/null
    unlink ~/Library/Containers/com.docker.helper &>/dev/null
    unlink ~/.docker &>/dev/null
    rm -rf ~/Library/Containers/com.docker.{docker,helper} ~/.docker &>/dev/null
    mkdir -p "$docker_destination"/{com.docker.{docker,helper},.docker}
    ln -sf "$docker_destination"/com.docker.docker ~/Library/Containers/com.docker.docker
    ln -sf "$docker_destination"/com.docker.helper ~/Library/Containers/com.docker.helper
    ln -sf "$docker_destination"/.docker ~/.docker
    open -g -a Docker
}

function 42_code() {
    echo 'code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}' >> $HOME/.zshrc
    source $HOME/.zshrc
}

function 42_ssh() {
    ssh-keygen -C "" -f ~/.ssh/id_rsa -N "" 2&>1 >/dev/null
    cat ~/.ssh/id_rsa.pub | awk '{print($2)}' | pbcopy
    echo $GREEN"SSH key copied to clipboard"$RESET
    echo you can add it to your intranet account trought the following link:
    echo The following link will be opend in 5 secondes $BLUE"https://profile.intra.42.fr/gitlab_users"$RESET
    sleep 5
    open https://profile.intra.42.fr/gitlab_users
}

function 42_nvm() {
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | zsh
    source $HOME/.nvm/nvm.sh
}

function 42_node() {
    if which nvm >/dev/null
        then
        nvm install node
    else
        echo "installing nvm first"
        42_nvm
        nvm install node
    fi
}

function 42_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]
        then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}

function 42_reset() {
    echo $RED"Are you sure you want to reset your session? $RESET (yes/no)"
    read -r answer
    if [ "$answer" = "yes" ]
        then
        touch $HOME/.reset
    else
        echo $YELLOW"Aborting"
    fi
}

function 42_help() {
    echo -e $GREEN" -clean: $RESET      clean your computer"
    echo -e $GREEN" -storage: $RESET    show your storage"
    echo -e $GREEN" -brew: $RESET       install brew"
    echo -e $GREEN" -docker: $RESET     install docker"
    echo -e $GREEN" -code: $RESET       add code command to your zsh"
    echo -e $GREEN" -ssh: $RESET        generate ssh key"
    echo -e $GREEN" -nvm: $RESET        install nvm"
    echo -e $GREEN" -node: $RESET       install node"
    echo -e $GREEN" -oh-my-zsh: $RESET  install oh-my-zsh"
    echo -e $GREEN" -reset: $RESET      reset your session"
    echo -e $GREEN" -help: $RESET       show this help"
}

function 42() {
    case $1 in
        "-clean") 42_clean 
        ;;
        "-storage") 42_storage
        ;;
        "-brew") 42_brew
        ;;
        "-docker") 42_docker
        ;;
        "-code") 42_code
        ;;
        "-ssh") 42_ssh
        ;;
        "-nvm") 42_nvm
        ;;
        "-node") 42_node
        ;;
        "-oh-my-zsh") 42_oh_my_zsh
        ;;
        "-reset") 42_reset
        ;;
        "-help") 42_help
        ;;
        *) echo 42: "Unknown command: $1" ; 42_help
        ;;
    esac
}
