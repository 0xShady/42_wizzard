#!/bin/zsh

cd ~

curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/42-wizzard.sh > ~/.tmp-wizzard
diff ~/.tmp-wizzard ~/.42-wizzard.sh > /dev/null 2>&1
if [ $? -eq 0 ];
then
	echo "$GREEN 42 wizzard is up to date $RESET"
	/bin/rm ~/.tmp-wizzard 2> /dev/null
else
	mv ~/.tmp-wizzard $HOME/.42-wizzard.sh 2> /dev/null
	chmod +x $HOME/.42-wizzard.sh
	WIZZARD_VERSION=$(cat ~/.42-wizzard.sh | grep "WIZZARD_VERSION=" | cut -d '"' -f 2)
	echo "42 wizzard updated to $GREEN v$WIZZARD_VERSION $RESET"
fi

source ~/.42-wizzard.sh
