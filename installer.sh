cd ~
curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/42.sh > .42-wizzard.sh
chmod +x .42-wizzard.sh
echo "source ~/.42-wizzard.sh" >> ~/.zshrc
printf "\e[1;32m 42 wizzard installed\n \033[0m"
printf "run \e[1;32m 42 -help \033[0m for more info\n"