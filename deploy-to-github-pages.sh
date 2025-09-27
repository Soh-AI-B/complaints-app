#!/bin/bash

# Flutter Web App Deployment Script for GitHub Pages
# Make this file executable: chmod +x deploy-to-github-pages.sh

echo "🚀 Starting Flutter Web Deployment to GitHub Pages..."

# Step 1: Clean and build for web
echo "📦 Building Flutter web app..."
flutter clean
flutter pub get
flutter build web --release

# Step 2: Create GitHub Actions workflow if it doesn't exist
mkdir -p .github/workflows
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy Flutter Web to GitHub Pages

on:
  push:
    branches: [ main, master ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      pages: write
      id-token: write
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build for web
      run: flutter build web --release
      
    - name: Setup Pages
      uses: actions/configure-pages@v3
      
    - name: Upload artifact
      uses: actions/upload-pages-artifact@v2
      with:
        path: './build/web'
        
    - name: Deploy to GitHub Pages
      id: deployment
      uses: actions/deploy-pages@v2
EOF

# Step 3: Initialize git if not already initialized
if [ ! -d ".git" ]; then
    echo "📝 Initializing Git repository..."
    git init
    git branch -M main
fi

# Step 4: Add and commit files
echo "📝 Committing files..."
git add .
git commit -m "Deploy Flutter web app to GitHub Pages" || echo "No changes to commit"

echo "✅ Setup complete!"
echo ""
echo "🔗 Next steps:"
echo "1. Create a new repository on GitHub"
echo "2. Add the remote: git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
echo "3. Push: git push -u origin main"
echo "4. Enable GitHub Pages in repository settings"
echo ""
echo "📱 Your app will be available at: https://YOUR_USERNAME.github.io/YOUR_REPO/"