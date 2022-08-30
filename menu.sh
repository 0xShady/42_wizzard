#!/bin/bash

function print_menu() # selected_item, ...menu_items
{
	local function_arguments=($@)

	local selected_item="$1"
	local menu_items=(${function_arguments[@]:1})
	local menu_size="${#menu_items[@]}"

	for (( i = 0; i < $menu_size; ++i ))
	do
		if [ "$i" = "$selected_item" ]
		then
			echo "-> ${menu_items[i]}"
		else
			echo "   ${menu_items[i]}"
		fi
	done
}

function run_menu() # selected_item, ...menu_items
{
	local function_arguments=($@)

	local selected_item="$1"
	local menu_items=(${function_arguments[@]:1})
	local menu_size="${#menu_items[@]}"
	local menu_limit=$((menu_size - 1))

	clear
	print_menu "$selected_item" "${menu_items[@]}"
	
	while read -rs -n 0.1 input
	do
		case "$input"
		in
			$'\x1B') # ESC ASCII code (https://dirask.com/posts/ASCII-Table-pJ3Y0j)
				read -rs -n 1 -t 0.1 input
				if [ "$input" = "[" ]  # occurs before arrow code
				then
					read -rs -n 1 -t 0.1 input
					case "$input"
					in
						A)  # Up Arrow
							if [ "$selected_item" -ge 1 ]
							then
								selected_item=$((selected_item - 1))
								clear
								print_menu "$selected_item" "${menu_items[@]}"
							fi
							;;
						B)  # Down Arrow
							if [ "$selected_item" -lt "$menu_limit" ]
							then
								selected_item=$((selected_item + 1))
								clear
								print_menu "$selected_item" "${menu_items[@]}"
							fi
							;;
					esac
				fi
				read -rs -n 5 -t 0.3  # flushing stdin
				;;
			"")  # Enter key
				return "$selected_item"
				;;
		esac
	done
}


# Usage example:

selected_item=0
menu_items=('Login' 'Register' 'Guest' 'Exit')

run_menu "$selected_item" "${menu_items[@]}"
menu_result="$?"

echo

case "$menu_result"
in
	0)
		echo 'Login item selected'
		;;
	1)
		echo 'Register item selected'
		;;
	2)
		echo 'Guest item selected'
		;;
	3)
		echo 'Exit item selected'
		;;
esac