
echo "Setting the THEME to agnoster..."

sed -i "s/^ZSH_THEME=\"[^\"]*\"/ZSH_THEME=\"agnoster\"/" "$HOME/.zshrc"

echo "Setting the CASE_SENSITIVE completion to true..."

sed -i 's/^# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/' "$HOME/.zshrc"
sed -i 's/^CASE_SENSITIVE="false"/CASE_SENSITIVE="true"/' "$HOME/.zshrc"

echo "Fixing oh-my-zsh uninstall script..."
sed -i 's/^  if chsh -s "$old_shell"; then/  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$old_shell" ] \&\& chsh -s "$old_shell"; then/' "$HOME/.oh-my-zsh/tools/uninstall.sh"

echo "Removing exit statements..."
sed -i 's/^.*exit.*$//' "$HOME/.oh-my-zsh/tools/uninstall.sh"