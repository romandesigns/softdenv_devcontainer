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

# --------------------------------------
# Base packages
# --------------------------------------
sudo apt-get update
sudo apt-get install -y \
  curl unzip fontconfig ca-certificates \
  build-essential pkg-config libssl-dev \
  python3 python3-pip \
  jq zip xz-utils file \
  adb openjdk-17-jdk

# --------------------------------------
# Watchman
# --------------------------------------
echo "👀 Installing Watchman..."
sudo apt-get install -y watchman || true
watchman --version || true

# --------------------------------------
# Media Processing Toolkit (Image/Video/Audio)
# --------------------------------------
echo "🎬 Installing media processing tools (image/video/audio)..."

sudo apt-get install -y \
  ffmpeg \
  imagemagick \
  libvips-tools libvips-dev \
  exiftool \
  mediainfo \
  sox \
  lame \
  flac \
  opus-tools \
  vorbis-tools \
  webp \
  pngquant \
  jpegoptim \
  gifsicle \
  ghostscript

echo "✅ Media tools installed:"
ffmpeg -version | head -n 1 || true
convert -version | head -n 1 || true
vips --version || true
sox --version || true
exiftool -ver || true
mediainfo --Version 2>/dev/null | head -n 1 || true

# --------------------------------------
# Desktop app dependencies
# --------------------------------------
echo "🖥️ Installing desktop app build dependencies..."
sudo apt-get install -y \
  libgtk-3-dev \
  libwebkit2gtk-4.1-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev \
  patchelf \
  libfuse2

# --------------------------------------
# Node.js + npm
# --------------------------------------
echo "🟢 Ensuring Node.js + npm are installed..."

if ! command -v npm >/dev/null 2>&1; then
  echo "📦 npm not found. Installing Node.js LTS (v20)..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  echo "✅ npm found: $(npm -v)"
fi

echo "✅ Node version: $(node -v 2>/dev/null || echo 'node not found')"
echo "✅ npm version: $(npm -v 2>/dev/null || echo 'npm not found')"

# --------------------------------------
# Global JS tooling
# --------------------------------------
echo "🧰 Installing useful global JS tooling..."

if command -v npm >/dev/null 2>&1; then
  npm install -g \
    sharp-cli \
    expo \
    eas-cli \
    @expo/ngrok \
    npm-check-updates \
    concurrently \
    typescript
else
  echo "⚠️ npm not found in current PATH. Skipping global JS tooling install."
fi

echo "✅ Expo version:"
expo --version || true

echo "✅ EAS version:"
eas --version || true

# --------------------------------------
# Bun global helpers
# --------------------------------------
echo "🥟 Installing Bun global helpers..."
bun add -g @biomejs/biome || true

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

source "$HOME/.cargo/env"

rustup component add rustfmt clippy || true

echo "🦀 Rust version:"
rustc --version
cargo --version

# --------------------------------------
# Tauri CLI
# --------------------------------------
echo "🚀 Installing Tauri CLI..."
cargo install tauri-cli --locked || true
cargo tauri --version || true

# --------------------------------------
# Android / Java checks
# --------------------------------------
echo "📱 Android / Java tooling versions:"
java -version || true
javac -version || true
adb version || true

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

# --------------------------------------
# Shell profile helpers
# --------------------------------------
echo "🧩 Adding developer environment exports..."

PROFILE_FILE="$HOME/.bashrc"

if ! grep -q 'ANDROID_HOME=' "$PROFILE_FILE"; then
  cat <<'EOF' >> "$PROFILE_FILE"

# Android / mobile development
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/emulator

# Rust / Cargo
export PATH=$HOME/.cargo/bin:$PATH
EOF
fi

# --------------------------------------
# Expo alias (devcontainer friendly)
# --------------------------------------
echo "⚡ Configuring Expo dev alias..."

ALIAS_LINE="alias expo-dev='bunx expo start --tunnel --port 0'"

if ! grep -Fxq "$ALIAS_LINE" "$HOME/.bashrc"; then
  echo "$ALIAS_LINE" >> "$HOME/.bashrc"
  echo "✅ Expo alias added to .bashrc"
else
  echo "ℹ️ Expo alias already exists"
fi

# Reload shell (safe)
. "$HOME/.bashrc" || true

echo "🏁 Finished $installation_type."