cd
curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/42.sh?token=GHSAT0AAAAAABWKAC5PML5XXC63CBWRVL22YW7YCKQ > .42-wizzard.sh
chmod +x .42-tools.sh
echo "source .42-tools.sh" >> .zshrc
echo "source .zshrc" | zsh
echo "42 wizzard installed"