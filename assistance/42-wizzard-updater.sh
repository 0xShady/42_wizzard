#!/bin/zsh

curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/42-wizzard.sh > $HOME/.tmp-wizzard
diff $HOME/.tmp-wizzard $HOME/.42-wizzard.sh
if [ $? -eq 0 ];
then
	printf "$GREEN 42 wizzard is up to date\n $RESET"
	rm ~/.tmp-wizzard
else
	mv ~/.tmp-wizzard $HOME/.42-wizzard.sh
	chmod +x $HOME/.42-wizzard.sh
	printf "42 wizzard updated \n"
fi
source $HOME/.42-wizzard.sh
