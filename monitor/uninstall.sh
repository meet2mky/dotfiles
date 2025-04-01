ZSHRC="$HOME/.zshrc"
BEGIN_MARKER="# --- BEGIN DOTFILE MONITOR ---"
END_MARKER="# --- END DOTFILE MONITOR ---"

if grep -q "$BEGIN_MARKER" "$ZSHRC"; then
  echo "Removing DOTFILE MONITOR from $ZSHRC..."
  # Use sed to remove the lines between the markers (inclusive)
  sed -i "/$BEGIN_MARKER/,/$END_MARKER/d" "$ZSHRC"
  echo "Dotfile monitor removed from $ZSHRC. You might need to source it (exec zsh) or open a new terminal."
else
  echo "Dotfile monitor markers not found in $ZSHRC. Assuming it was not managed by this script."
fi