#!/bin/bash


####################### DESCRIPTION: #######################
#
# multiselect is a pure bash implementation of a multi
# selection menu.
#
# If "true" is passed as first argument a help (similar to
# the overview in section "USAGE") will be printed before
# showing the options. Any other value will hide it.
#
# The result will be stored as an array in a variable
# that is passed to multiselect as second argument.
#
# The third argument takes an array that contains all
# available options.
#
# The last argument is optional and can be used to
# preselect certain options. If used it must be an array
# that has a value of "true" for every index of the options
# array that should be preselected.
#
########################## USAGE: ##########################
#
#   j or ↓        => down
#   k or ↑        => up
#   ⎵ (Space)     => toggle selection
#   ⏎ (Enter)     => confirm selection
#
######################### EXAMPLE: #########################
#
# source <(curl -sL multiselect.miu.io)
#
# my_options=(   "Option 1"  "Option 2"  "Option 3" )
# preselection=( "true"      "true"      "false"    )
#
# multiselect "true" result my_options preselection
#
# idx=0
# for option in "${my_options[@]}"; do
#     echo -e "$option\t=> ${result[idx]}"
#     ((idx++))
# done
#
############################################################

function multiselect {
    echo "${array[@]:0:1}"
    if [[ $1 = "true" ]]; then
        echo -e "j or ↓\t\t=> down"
        echo -e "k or ↑\t\t=> up"
        echo -e "⎵ (Space)\t=> toggle selection"
        echo -e "⏎ (Enter)\t=> confirm selection"
        echo
    fi

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()   { printf "$ESC[?25h"; }
    cursor_blink_off()  { printf "$ESC[?25l"; }
    cursor_to()         { printf "$ESC[$1;${2:-1}H"; }
    print_inactive()    { printf "$2   $1 "; }
    print_active()      { printf "$2  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }

    local return_value=$2
    local options=$3
    local defaults=$4

    local selected=()
    for ((i=0; i<${#options[@]}; i++)); do
        if [[ ${defaults[i]} = "true" ]]; then
            selected+=("true")
        else
            selected+=("false")
        fi
        printf "\n"
    done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - ${#options[@]}))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    key_input() {
        local key
        IFS= read -rsn1 key 2>/dev/null >&2
        if [[ $key = ""      ]]; then echo enter; fi;
        if [[ $key = $'\x20' ]]; then echo space; fi;
        if [[ $key = "k" ]]; then echo up; fi;
        if [[ $key = "j" ]]; then echo down; fi;
        if [[ $key = $'\x1b' ]]; then
            read -rsn2 key
            if [[ $key = [A || $key = k ]]; then echo up;    fi;
            if [[ $key = [B || $key = j ]]; then echo down;  fi;
        fi
    }

    toggle_option() {
        local option=$1
        if [[ ${selected[option]} == true ]]; then
            selected[option]=false
        else
            selected[option]=true
        fi
    }

    print_options() {
        # print options by overwriting the last lines
        local idx=0
        for option in "${options[@]}"; do
            local prefix="[ ]"
            if [[ ${selected[idx]} == true ]]; then
              prefix="[\e[38;5;46m✔\e[0m]"
            fi

            cursor_to $(($startrow + $idx))
            if [ $idx -eq $1 ]; then
                print_active "$option" "$prefix"
            else
                print_inactive "$option" "$prefix"
            fi
            ((idx++))
        done
    }

    local active=0
    while true; do
        print_options $active

        # user key control
        case `key_input` in
            space)  toggle_option $active;;
            enter)  print_options -1; break;;
            up)     ((active--));
                    if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
            down)   ((active++));
                    if [ $active -ge ${#options[@]} ]; then active=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    eval $return_value='("${selected[@]}")'
}

my_options=(   "Option 1"  "Option 2"  "Option 3" )
preselection=( "true"      "true"      "false"    )

multiselect "true" result my_options preselection

idx=0
for option in "${my_options[@]}"; do
    echo -e "$option\t=> ${result[idx]}"
    ((idx++))
done