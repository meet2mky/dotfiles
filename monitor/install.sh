# Add dotfile monitor script to ~/.zshrc
ZSHRC="$HOME/.zshrc"

BEGIN_MARKER=                 "# --- BEGIN DOTFILE MONITOR ---"
DOTFILE_MONITOR_LINE=         "bash $HOME/dotfiles/monitor/main.sh &!"
ADD_FILE_PATH=                "TEMP_FILE=\"/tmp/dotfiles_changed\""
ADD_CODE_1=                   "if [ -f \"$TEMP_FILE\" ]; then"
ADD_CODE_2=                   "   echo \"Dotfile changes detected...\""
ADD_CODE_3=                   "fi"
END_MARKER=                   "# --- END DOTFILE MONITOR ---"

# Check if the markers are already present to avoid duplicates
if grep -q "$BEGIN_MARKER" "$ZSHRC"; then
  echo "Dotfile monitor already present in $ZSHRC."
  exit 1
else
  echo "Adding Dotfile monitor to $ZSHRC..."
  cat <<EOF >> "$ZSHRC"
$BEGIN_MARKER
$DOTFILE_MONITOR_LINE
$ADD_FILE_PATH
$ADD_CODE_1
$ADD_CODE_2
$ADD_CODE_3
$END_MARKER
EOF
  echo "Dotfile monitor added to $ZSHRC. You might need to source it (exec zsh) or open a new terminal."
fi

cat $ZSHRC