#! /usr/bin/bash
set -e

installation_type="custom installations"
FONT_NAME="CascadiaCode Nerd Font"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip"
FONT_DIR="/usr/local/share/fonts/cascadia-code"
TMP_DIR="/tmp/fonts"

echo "⚙️  Starting $installation_type..."

echo "📦 Installing required packages..."
sudo apt-get update
sudo apt-get install -y curl unzip fontconfig

echo "🔤 Installing $FONT_NAME..."

mkdir -p "$TMP_DIR"
sudo mkdir -p "$FONT_DIR"

curl -L "$FONT_URL" -o "$TMP_DIR/cascadia.zip"
unzip -o "$TMP_DIR/cascadia.zip" -d "$TMP_DIR"

sudo find "$TMP_DIR" -name "*.ttf" -exec mv {} "$FONT_DIR" \;

sudo fc-cache -fv

echo "✅ $FONT_NAME installed successfully"
echo "🏁 Finishing $installation_type..."
