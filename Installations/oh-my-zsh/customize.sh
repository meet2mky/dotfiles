
echo "Setting the THEME to agnoster..."

sed -i "s/^ZSH_THEME=\"[^\"]*\"/ZSH_THEME=\"agnoster\"/" "$HOME/.zshrc"

echo "Setting the CASE_SENSITIVE completion to true..."

sed -i 's/^# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/' "$HOME/.zshrc"
sed -i 's/^CASE_SENSITIVE="false"/CASE_SENSITIVE="true"/' "$HOME/.zshrc"
