# Web Deployment Guide

This guide explains how to deploy the Complaints Management System to the web using Vercel, with automatic platform detection and routing.

## Overview

The app now supports three deployment strategies:

1. **Android Native**: Full native Android app with all features
2. **iOS Redirect to Web**: iOS users are automatically redirected to web version
3. **Web Direct**: Users can access the web version directly via URL

## Platform Detection & Routing

### How It Works

1. **Platform Detection**: The app detects if it's running on Android, iOS, or Web
2. **Automatic Routing**:
   - Android users: Continue with native app
   - iOS users: Prompted to use web version (since iOS development costs money)
   - Users with device issues: Can opt for web fallback
   - Web users: Use the web version directly

### Services Involved

- `PlatformService`: Detects current platform
- `WebRedirectService`: Handles web redirection logic
- `UnifiedImagePicker`: Cross-platform image handling

## Deployment Steps

### 1. Prerequisites

- Node.js and npm installed
- Vercel CLI: `npm i -g vercel`
- Flutter SDK
- Firebase project with web configuration

### 2. Configure Firebase for Web

Ensure your `firebase_options.dart` has the correct web configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-web-api-key',
  appId: 'your-web-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'your-project-id',
  authDomain: 'your-project.firebaseapp.com',
  storageBucket: 'your-project.firebasestorage.app',
  measurementId: 'G-XXXXXXXXXX',
);
```

### 3. Update Vercel Configuration

Edit `vercel.json` with your actual Firebase service account:

```json
{
  "version": 2,
  "builds": [
    {
      "src": "lib/main.dart",
      "use": "@vercel/flutter"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/lib/main.dart"
    }
  ],
  "functions": {
    "lib/main.dart": {
      "runtime": "@vercel/flutter"
    }
  },
  "env": {
    "FIREBASE_SERVICE_ACCOUNT_KEY": "@firebase-service-account-key"
  }
}
```

### 4. Build and Deploy

#### Option A: Using the Build Script

```bash
# Build for web
./build.sh web

# The script will prompt for Vercel deployment
```

#### Option B: Manual Deployment

```bash
# Build the web app
flutter build web --release --web-renderer canvaskit

# Deploy backend to Vercel
cd vercel_backend
vercel --prod

# The web app will be served from the same domain
```

### 5. Environment Variables

Set these in your Vercel dashboard or `.env` file:

- `FIREBASE_SERVICE_ACCOUNT_KEY`: Your Firebase service account JSON (base64 encoded)

## Mobile App Configuration

### Android App

The Android app remains unchanged and works natively.

### iOS App (Optional)

If you still want to publish an iOS app, you can:

1. Build the app normally: `flutter build ios --release`
2. The app will still prompt users to use the web version
3. Or modify `PlatformService` to allow iOS users to continue with native app

## Web-Specific Features

### Responsive Design

- Desktop: Centered layout with max-width of 1200px
- Tablet: Optimized grid layouts
- Mobile: Standard mobile-first design

### Image Handling

- Web uses `image_picker_for_web` for file selection
- Mobile uses native `image_picker`
- Unified API through `UnifiedImagePicker`

### Notifications

- Web: Browser notifications (when permission granted)
- Mobile: Native push notifications via FCM

## Testing

### Platform Detection

Test on different platforms:

```dart
// Check platform detection
print(PlatformService.currentPlatform); // AppPlatform.android/ios/web

// Check if should redirect
print(PlatformService.shouldRedirectToWeb()); // true/false
```

### Web Responsiveness

Test on different screen sizes:
- Mobile: < 600px
- Tablet: 600-1200px
- Desktop: > 1200px

### Build Testing

```bash
# Test web build locally
flutter run -d web-server --web-port 3000

# Test Android build
flutter run -d android

# Test iOS build (on macOS)
flutter run -d ios
```

## URL Structure

After deployment, your app will be available at:
- Web version: `https://your-app-name.vercel.app`
- Backend API: `https://your-app-name.vercel.app/api/*`

## Troubleshooting

### Web Build Issues

1. **CanvasKit renderer**: Use `--web-renderer canvaskit` for better performance
2. **Firebase configuration**: Ensure web config is correct in `firebase_options.dart`
3. **CORS issues**: Backend API handles CORS automatically

### Platform Detection Issues

1. **Web detection**: Check `kIsWeb` and `PlatformService.isWeb`
2. **iOS detection**: Ensure proper platform detection logic
3. **Redirect not working**: Check `WebRedirectService` implementation

### Deployment Issues

1. **Vercel build fails**: Check Flutter version compatibility
2. **Environment variables**: Ensure Firebase credentials are set
3. **Routes not working**: Verify `vercel.json` configuration

## Performance Optimization

### Web-Specific Optimizations

1. **Tree shaking**: Flutter web automatically tree shakes unused code
2. **Lazy loading**: Use deferred imports for large features
3. **Image optimization**: Compress images before upload
4. **Caching**: Implement proper caching strategies

### Monitoring

- Use Firebase Analytics to track platform usage
- Monitor web vitals with Lighthouse
- Track redirect rates and user preferences

## Future Enhancements

1. **Progressive Web App (PWA)**: Add service worker for offline functionality
2. **WebAssembly**: Consider using WASM for performance-critical features
3. **Server-Side Rendering**: Implement SSR for better SEO
4. **Multi-tenant**: Support multiple organizations on same deployment

## Cost Considerations

### Free Tier Benefits

- **Vercel**: Generous free tier for personal projects
- **Firebase**: Free tier covers most small business needs
- **Flutter Web**: No additional costs for web deployment

### Paid Alternatives

If you exceed free tiers:
- **Vercel Pro**: $20/month for higher limits
- **Firebase Blaze**: Pay-as-you-go for heavy usage
- **Dedicated hosting**: For enterprise deployments

## Security

### Web Security

1. **HTTPS**: Vercel provides SSL certificates automatically
2. **CSP Headers**: Configured in `vercel.json`
3. **Firebase Security Rules**: Properly configured for web access
4. **Input Validation**: All user inputs validated on client and server

### Data Protection

1. **Firebase Security**: Row-level security with Firestore rules
2. **Authentication**: Firebase Auth handles user sessions
3. **Data Encryption**: Firebase encrypts data at rest and in transit

## Support

For issues related to web deployment:

1. Check Flutter web documentation
2. Review Vercel deployment logs
3. Test Firebase configuration
4. Verify platform detection logic

The web version provides the same functionality as the mobile app while avoiding iOS development costs and providing better accessibility for users with device issues.

