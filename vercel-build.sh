#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Vercel build script — installs Flutter and builds Flutter Web
# Runs inside Vercel's Ubuntu build environment on every deployment
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

FLUTTER_VERSION="3.35.7"
FLUTTER_DIR="/opt/flutter"

echo ">>> Installing Flutter $FLUTTER_VERSION..."
git clone \
  --depth 1 \
  --branch "$FLUTTER_VERSION" \
  https://github.com/flutter/flutter.git \
  "$FLUTTER_DIR"

export PATH="$FLUTTER_DIR/bin:$PATH"

echo ">>> Configuring Flutter (no analytics, web only)..."
flutter config --no-analytics
flutter precache --web

echo ">>> Installing pub dependencies..."
flutter pub get

echo ">>> Building Flutter Web (release)..."
flutter build web \
  --release \
  --no-tree-shake-icons \
  --base-href /

echo ">>> Build complete — output in build/web/"
