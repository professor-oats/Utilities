#!/usr/bin/env bash
#
# install-teams-multi.sh
# Installs a separate Teams-for-Linux instance with isolated config
# Usage:
#   ./install-teams-multi.sh companyB
#
# Example:
#   ./install-teams-multi.sh companyB
#   Then run: teams-for-linux-companyB
#

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <profile-name>"
  exit 1
fi

PROFILE="$1"
BASE_DIR="$HOME/teams-for-linux-$PROFILE"
CONFIG_DIR="$HOME/.config/teams-for-linux-$PROFILE"
CACHE_DIR="$HOME/.cache/teams-for-linux-$PROFILE"
LAUNCHER="$HOME/.local/bin/teams-for-linux-$PROFILE"
DEB_URL="https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v2.6.7/teams-for-linux_2.6.7_amd64.deb" # change to latest if needed
TMP_DEB="/tmp/teams-$PROFILE.deb"

echo "➡️  Setting up Microsoft Teams for profile: $PROFILE"
echo "   Base directory: $BASE_DIR"
echo "   Config: $CONFIG_DIR"
echo "   Cache:  $CACHE_DIR"
echo ""

# 1. Create directories
mkdir -p "$BASE_DIR" "$CONFIG_DIR" "$CACHE_DIR" "$HOME/.local/bin"

# 2. Download package
echo "⬇️  Downloading Teams package..."
wget -q -O "$TMP_DEB" "$DEB_URL"

# 3. Extract contents (no system install)
echo "📦  Extracting Teams to $BASE_DIR ..."
dpkg-deb -x "$TMP_DEB" "$BASE_DIR"

# 4. Create launch wrapper
echo "⚙️  Creating launcher script: $LAUNCHER ..."
cat > "$LAUNCHER" <<EOF
#!/usr/bin/env bash
XDG_CONFIG_HOME="$CONFIG_DIR" \\
XDG_CACHE_HOME="$CACHE_DIR" \\
exec "$BASE_DIR/opt/teams-for-linux/teams-for-linux" --user-data-dir="$CONFIG_DIR" "\$@"
EOF

chmod +x "$LAUNCHER"

# 5. (Optional) Add to PATH if not present
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "✅ Added ~/.local/bin to your PATH (effective on next shell login)."
fi

echo ""
echo "✅ Installation complete!"
echo "Run your new instance using:"
echo "   $LAUNCHER"
echo ""
echo "or just:"
echo "   teams-for-linux-$PROFILE"
