cd ~
curl https://raw.githubusercontent.com/0xShady/42_wizzard/main/42.sh?token=GHSAT0AAAAAABWKAC5PML5XXC63CBWRVL22YW7YCKQ > .42-wizzard.sh
sleep 1
chmod +x .42-wizzard.sh
echo "source .42-wizzard.sh" >> ~/.zshrc
echo "source ~/.zshrc" | zsh
echo 
echo "\e[1;32m" "42 wizzard installed" "\033[0m"