#! /usr/bin/bash
set -e

installation_type="custom installations"

# Font details
FONT_NAME="CascadiaCode Nerd Font"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
FONT_DIR="/usr/local/share/fonts/cascadia-code"
TMP_DIR="/tmp/fonts"

# Git details
GIT_NAME="Roman F."
GIT_EMAIL="wavystyledev@gmail.com"

echo "⚙️ Starting $installation_type..."
echo "📦 Installing required packages..."

# --------------------------------------
# Fix: Yarn APT repo EXPKEYSIG issue
# --------------------------------------
if [ -f /etc/apt/sources.list.d/yarn.list ]; then
  echo "🧹 Removing Yarn APT repo (expired signing key)..."
  sudo rm -f /etc/apt/sources.list.d/yarn.list
fi

if [ -f /usr/share/keyrings/yarn-archive-keyring.gpg ]; then
  echo "🧹 Removing Yarn APT keyring..."
  sudo rm -f /usr/share/keyrings/yarn-archive-keyring.gpg
fi

sudo apt-get update
sudo apt-get install -y curl unzip fontconfig ca-certificates build-essential pkg-config libssl-dev

# --------------------------------------
# Rust Installation (Always Latest Stable)
# --------------------------------------

echo "🦀 Installing latest Rust (stable)..."

if ! command -v rustup >/dev/null 2>&1; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
else
  echo "🔄 Rustup already installed. Updating toolchain..."
  rustup self update
  rustup update stable
  rustup default stable
fi

# Load cargo into PATH for current session
source "$HOME/.cargo/env"

echo "🦀 Rust version:"
rustc --version
cargo --version

# --------------------------------------
# Fonts Installation
# --------------------------------------

echo "🔤 Installing $FONT_NAME..."
mkdir -p "$TMP_DIR"
sudo mkdir -p "$FONT_DIR"

curl -L "$FONT_URL" -o "$TMP_DIR/cascadia.zip"
unzip -o "$TMP_DIR/cascadia.zip" -d "$TMP_DIR"

sudo find "$TMP_DIR" -name "*.ttf" -exec mv {} "$FONT_DIR" \;

sudo fc-cache -fv

echo "✅ $FONT_NAME installed successfully"

# --------------------------------------
# Global Git identity
# --------------------------------------

echo "🌍 Setting global Git identity..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main

# --------------------------------------
# SSH perms (for mounted ~/.ssh)
# --------------------------------------

echo "🔐 Setting SSH directory permissions..."
if [ -d "/home/vscode/.ssh" ]; then
  chmod 700 /home/vscode/.ssh || true
  chmod 600 /home/vscode/.ssh/id_ed25519 2>/dev/null || true
  chmod 644 /home/vscode/.ssh/id_ed25519.pub 2>/dev/null || true
fi

echo "🏁 Finished $installation_type."
