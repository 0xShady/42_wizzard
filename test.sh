#!/bin/bash

function wizzard-select-option() {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

my_options=("option 1" "option 2" "option 3")

wizzard-select-option "${my_options[@]}"
echo "You selected: $?"

# function 42-wizzard-init() {
# 	# check if .42-env is present
# 	if [ ! -f "$HOME/.42-env" ]
# 		then
# 		echo "this is the first time you are using this command"
# 		echo "might take a while, but it's a one time configuration"
# 		echo "do you wish to continue? (yes/no)"
# 		read -r ANSWER
# 		if [ "$ANSWER" != "yes" ]
# 			then
# 			exit 0
# 		fi
# 		# dark theme
# 		echo "Do you prefer to use the dark theme? (yes/no)"
# 		read -r ANSWER
# 		if [ "$ANSWER" = "yes" ]
# 			then
# 			echo "THEME=dark" > $HOME/.42-env
# 		else
# 			echo "THEME=light" > $HOME/.42-env
# 		fi
# 		# bluetooth device
# 		echo "Please enter the name of your bluetooth device(Leave empty to skip)"
# 		read -r ANSWER
# 		if [ "$ANSWER" != "" ]
# 			then
# 			echo "BLUETOOTH=\"$ANSWER\"" >> $HOME/.42-env
# 		fi
# 		echo "Your configuration is done!"
# 	fi
# 	# check if blueutil is installed
# 	if which blueutil > /dev/null
# 		then
# 		sleep 1
# 	else
# 		if which brew > /dev/null
# 			then
# 			brew install blueutil > /dev/null 2>&1
# 		else
# 			echo "please install brew first"
# 			echo "42 -brew"
# 			exit 0
# 		fi
# 	fi
# 	# source .42-env
# 	source $HOME/.42-env > /dev/null 2>&1
# 	# set theme to dark if dark is set in .42-env
# 	if [ $THEME = "dark" ]
# 		then
# 		echo "setting theme to dark"
# 		osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
# 	fi
# 	# activate bluetooth
# 	echo "activating bluetooth..."
# 	blueutil -p 1 > /dev/null 2>&1
# 	sleep 3
# 	bt=$(blueutil --is-connected "$BLUETOOTH")
# 	if [ $bt = 0 ]
# 		then
# 		blueutil --connect "$BLUETOOTH" > /dev/null 2>&1
# 		if [ $? -eq 0 ]
# 			then
# 			echo "$GREEN $BLUETOOTH connected!"
# 		else
# 			echo "$RED cannot connecte to $BLUETOOTH"
# 		fi
# 	else
# 		echo "$GREEN $BLUETOOTH is already connected! \n"
# 	fi
# }

# function 42-wizzard-config() {
#     local themes=( "light" "dark" )
#     local binary_options=( "yes" "no" )
#     local dock_options=( "left" "right" "bottom" )
#     if [ -f "$HOME/.42-env" ]
#         then
#         source $HOME/.42-env > /dev/null 2>&1
#         echo "configuration already done"
#     fi
#     echo "What theme do you want to use?"
#     wizzard-select-option theme"${themes[@]}"
#     THEME=$?
#     if [ $THEME = 0 ]
#         then
#         echo "THEME=dark" > $HOME/.42-env
#     else
#         echo "THEME=light" > $HOME/.42-env
#     fi
#     echo "Where do you prefer your dock to be?"
#     wizzard-select-option "${dock_options[@]}"
#     DOCK=$?
#     if [ $DOCK = 0 ]
#         then
#         echo "DOCK=left" >> $HOME/.42-env
#     elif [ $DOCK = 1 ]
#         then
#         echo "DOCK=right" >> $HOME/.42-env
#     else
#         echo "DOCK=bottom" >> $HOME/.42-env
#     fi
#     echo "Do you wanna specify a bluetooth device?"
#     wizzard-select-option "${binary_options[@]}"
#     BLUETOOTH=$?
#     if [ $BLUETOOTH = 0 ]
#         then
#         echo "Please enter the name of your bluetooth device"
#         read -r ANSWER
#         echo "BLUETOOTH=\"$ANSWER\"" >> $HOME/.42-env
#     fi
#     echo "Do you wanna specify a wallpaper?"
#     wizzard-select-option "${binary_options[@]}"
#     WALLPAPER=$?
#     if [ $WALLPAPER = 0 ]
#         then
#         echo "Please enter the path to your wallpaper"
#         read -r ANSWER
#         echo "WALLPAPER=\"$ANSWER\"" >> $HOME/.42-env
#     fi
# }

# 42-wizzard-config

# cat $HOME/.42-env

# function multiselect {
#     # little helpers for terminal print control and key input
#     ESC=$( printf "\033")
#     cursor_blink_on()   { printf "$ESC[?25h"; }
#     cursor_blink_off()  { printf "$ESC[?25l"; }
#     cursor_to()         { printf "$ESC[$1;${2:-1}H"; }
#     print_inactive()    { printf "$2   $1 "; }
#     print_active()      { printf "$2  $ESC[7m $1 $ESC[27m"; }
#     get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }

#     local return_value=$1
#     local  options=$2
#     local  defaults=$3

#     local selected=()
#     for ((i=0; i<${#options[@]}; i++)); do
#         if [[ ${defaults[i]} = "true" ]]; then
#             selected+=("true")
#         else
#             selected+=("false")
#         fi
#         printf "\n"
#     done

#     # determine current screen position for overwriting the options
#     local lastrow=`get_cursor_row`
#     local startrow=$(($lastrow - ${#options[@]}))

#     # ensure cursor and input echoing back on upon a ctrl+c during read -s
#     trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
#     cursor_blink_off

#     key_input() {
#         local key
#         IFS= read -rsn1 key 2>/dev/null >&2
#         if [[ $key = ""      ]]; then echo enter; fi;
#         if [[ $key = $'\x20' ]]; then echo space; fi;
#         if [[ $key = "k" ]]; then echo up; fi;
#         if [[ $key = "j" ]]; then echo down; fi;
#         if [[ $key = $'\x1b' ]]; then
#             read -rsn2 key
#             if [[ $key = [A || $key = k ]]; then echo up;    fi;
#             if [[ $key = [B || $key = j ]]; then echo down;  fi;
#         fi
#     }

#     toggle_option() {
#         local option=$1
#         if [[ ${selected[option]} == true ]]; then
#             selected[option]=false
#         else
#             selected[option]=true
#         fi
#     }

#     print_options() {
#         # print options by overwriting the last lines
#         local idx=0
#         for option in "${options[@]}"; do
#             local prefix="[ ]"
#             if [[ ${selected[idx]} == true ]]; then
#               prefix="[\e[38;5;46m✔\e[0m]"
#             fi

#             cursor_to $(($startrow + $idx))
#             if [ $idx -eq $1 ]; then
#                 print_active "$option" "$prefix"
#             else
#                 print_inactive "$option" "$prefix"
#             fi
#             ((idx++))
#         done
#     }

#     local active=0
#     while true; do
#         print_options $active

#         # user key control
#         case `key_input` in
#             space)  toggle_option $active;;
#             enter)  print_options -1; break;;
#             up)     ((active--));
#                     if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
#             down)   ((active++));
#                     if [ $active -ge ${#options[@]} ]; then active=0; fi;;
#         esac
#     done

#     # cursor position back to normal
#     cursor_to $lastrow
#     printf "\n"
#     cursor_blink_on

#     eval $return_value='("${selected[@]}")'
# }

# my_options=(   "Option 1"  "Option 2"  "Option 3" )
# preselection=( "true"      "true"      "false"    )

# source menu.sh

# multiselect result my_options
#/bin/bash
# by oToGamez
# www.pro-toolz.net

