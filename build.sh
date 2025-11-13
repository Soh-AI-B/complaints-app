#!/bin/bash

# Build script for Complaints App
# Supports Android, iOS, Web, and Vercel deployment

set -e  # Exit on any error

echo "🚀 Complaints App Build Script"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Flutter installation
if ! command_exists flutter; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter version: $(flutter --version | head -n 1)"

# Get build target from arguments
TARGET=${1:-web}
PLATFORM=${2:-all}

print_status "Build target: $TARGET"
print_status "Platform: $PLATFORM"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

case $TARGET in
    "android")
        print_status "Building for Android..."

        if [ "$PLATFORM" = "apk" ]; then
            print_status "Building APK..."
            flutter build apk --release
            print_success "APK built successfully: build/app/outputs/flutter-apk/app-release.apk"
        elif [ "$PLATFORM" = "aab" ]; then
            print_status "Building AAB..."
            flutter build appbundle --release
            print_success "AAB built successfully: build/app/outputs/bundle/release/app-release.aab"
        else
            print_status "Building both APK and AAB..."
            flutter build apk --release
            flutter build appbundle --release
            print_success "Android builds completed"
        fi
        ;;

    "web")
        print_status "Building for Web..."

        # Build web app (compatible with Flutter 3.32.8)
        flutter build web --release

        print_success "Web build completed in build/web/"

        # Check if Vercel CLI is available for deployment
        if command_exists vercel; then
            read -p "Deploy to Vercel? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_status "Deploying to Vercel..."
                cd vercel_backend
                vercel --prod
                cd ..
                print_success "Deployed to Vercel"
            fi
        else
            print_warning "Vercel CLI not found. Install with: npm i -g vercel"
            print_status "To deploy manually: cd vercel_backend && vercel --prod"
        fi
        ;;

    "ios")
        print_status "Building for iOS..."

        if command_exists xcodebuild; then
            flutter build ios --release --no-codesign
            print_success "iOS build completed"
            print_warning "Note: iOS build requires code signing for App Store deployment"
        else
            print_error "Xcode not found. iOS builds require macOS with Xcode"
            exit 1
        fi
        ;;

    "all")
        print_status "Building for all platforms..."

        # Build Android
        print_status "Building Android APK..."
        flutter build apk --release

        # Build Web
        print_status "Building Web..."
        flutter build web --release

        # Build iOS if on macOS
        if command_exists xcodebuild; then
            print_status "Building iOS..."
            flutter build ios --release --no-codesign
        else
            print_warning "Skipping iOS build (requires macOS with Xcode)"
        fi

        print_success "All builds completed"
        ;;

    *)
        print_error "Invalid target: $TARGET"
        echo "Usage: $0 {android|web|ios|all} [platform]"
        echo "Examples:"
        echo "  $0 web                    # Build web"
        echo "  $0 android apk           # Build Android APK"
        echo "  $0 android aab           # Build Android AAB"
        echo "  $0 all                   # Build all platforms"
        exit 1
        ;;
esac

print_success "Build script completed!"
