# Deploy Flutter Web App to GitHub Pages (FREE)

## Prerequisites
1. GitHub account (free)
2. Your Flutter project in a GitHub repository

## Step 1: Build for Production
```bash
cd /home/sohaib-dev/Work/Complaints/complaints
flutter build web --release
```

## Step 2: Create GitHub Repository
1. Go to GitHub.com
2. Create a new repository named `complaints-web-app`
3. Push your Flutter project to this repository

## Step 3: Setup GitHub Actions for Auto-Deployment
Create `.github/workflows/deploy.yml` in your project:

```yaml
name: Deploy Flutter Web to GitHub Pages

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build for web
      run: flutter build web --release --base-href "/complaints-web-app/"
      
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
```

## Step 4: Enable GitHub Pages
1. Go to your repository Settings
2. Scroll to "Pages" section
3. Source: "Deploy from a branch"
4. Branch: "gh-pages"
5. Save

## Result
Your app will be available at: `https://yourusername.github.io/complaints-web-app/`

## Advantages
- ✅ Completely FREE
- ✅ Automatic HTTPS
- ✅ Auto-deploy on code changes
- ✅ Custom domain support (optional)
- ✅ Global CDN
- ✅ 1GB storage limit (more than enough)