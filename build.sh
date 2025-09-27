#!/bin/bash

# Vercel build script for Flutter Web
set -e

echo "🔧 Installing Flutter..."

# Download and install Flutter
export FLUTTER_VERSION="3.24.0"
export PATH="$PATH:/vercel/flutter/bin"

if [ ! -d "/vercel/flutter" ]; then
    cd /vercel
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
    tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
    rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
fi

# Add Flutter to PATH
export PATH="$PATH:/vercel/flutter/bin"

# Verify Flutter installation
flutter --version

echo "📦 Installing dependencies..."
flutter pub get

echo "🏗️ Building for web..."
flutter build web --release

echo "✅ Build complete!"
ls -la build/web/