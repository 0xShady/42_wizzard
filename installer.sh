cd ~
/bin/rm -rf .42-wizzard.sh .42-wizzard-loading.sh > /dev/null 2>&1
sed -n '/42-wizzard/!p' ~/.zshrc > .tmp && mv .tmp ~/.zshrc
curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/42-wizzard.sh > .42-wizzard.sh
chmod +x .42-wizzard.sh
echo "source ~/.42-wizzard.sh" >> ~/.zshrc
cd -
printf "\e[1;32m 42 wizzard installed\n \033[0m"
printf "run \e[1;32m 42 -help \033[0m for more info\n"