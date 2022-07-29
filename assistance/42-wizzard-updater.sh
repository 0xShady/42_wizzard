#!/bin/zsh

curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/42-wizzard.sh > $HOME/.tmp-wizzard
curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/assistance/42-wizzard-loading.sh > $HOME/.tmp-loading

diff $HOME/.tmp-wizzard $HOME/.42-wizzard.sh > /dev/null 2>&1
if [ $? -eq 0 ]
then
	# printf "$GREEN 42 wizzard is up to date\n $RESET"
	rm ~/.tmp-wizzard
else
	mv ~/.tmp-wizzard $HOME/.42-wizzard.sh
	chmod +x $HOME/.42-wizzard.sh
	printf "42 wizzard updated \n"
fi

diff $HOME/.tmp-loading $HOME/.42-wizzard-loading.sh > /dev/null 2>&1
if [ $? -eq 0 ]
then
	# printf "$GREEN 42 wizzard loading is up to date\n $RESET"
	rm ~/.tmp-loading
else
	mv ~/.tmp-loading $HOME/.42-wizzard-loading.sh
	chmod +x $HOME/.42-wizzard-loading.sh
	printf "42 wizzard loading updated \n"
fi

source $HOME/.42-wizzard.sh
