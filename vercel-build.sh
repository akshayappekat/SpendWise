#!/bin/bash

# Vercel Flutter Web Build Script
echo "Downloading Flutter SDK on Vercel..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

echo "Verifying Flutter Installation..."
flutter doctor -v

echo "Building Flutter Web Release Bundle..."
flutter build web --release

echo "Build Completed Successfully!"
