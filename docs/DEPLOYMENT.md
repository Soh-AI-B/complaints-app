# Deployment Guide

This guide covers deployment of the Complaints Manager application across different platforms.

## Prerequisites

- Flutter SDK 3.8.1+
- Firebase project with enabled services
- Platform-specific development tools
- CI/CD pipeline (optional)

## Environment Setup

### Development Environment

1. **Flutter Installation**
   ```bash
   # Install Flutter SDK
   git clone https://github.com/flutter/flutter.git
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Verify installation
   flutter doctor
   ```

2. **Firebase Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in project
   firebase init
   ```

3. **Configure Environment Variables**
   ```bash
   # Create .env file
   cp .env.example .env
   
   # Edit with your configuration
   nano .env
   ```

### Production Environment

1. **Firebase Project Configuration**
   - Enable Authentication (Email/Password)
   - Set up Firestore with security rules
   - Configure Firebase Storage
   - Enable Cloud Messaging
   - Set up hosting (for web)

2. **Security Rules Setup**
   ```javascript
   // Firestore rules
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Production security rules
     }
   }
   ```

## Android Deployment

### Build Configuration

1. **Update `android/app/build.gradle`**
   ```gradle
   android {
       compileSdkVersion 34
       minSdkVersion 21
       targetSdkVersion 34
       versionCode flutterVersionCode.toInteger()
       versionName flutterVersionName
   }
   ```

2. **Configure signing**
   ```bash
   # Generate keystore
   keytool -genkey -v -keystore ~/complaints-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias complaints
   
   # Create key.properties
   echo "storePassword=your_store_password" > android/key.properties
   echo "keyPassword=your_key_password" >> android/key.properties
   echo "keyAlias=complaints" >> android/key.properties
   echo "storeFile=/path/to/complaints-keystore.jks" >> android/key.properties
   ```

3. **Update build.gradle for signing**
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

### Build Commands

```bash
# Clean build
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Install on device
flutter install --release
```

### Play Store Deployment

1. **Prepare app bundle**
   ```bash
   flutter build appbundle --release
   ```

2. **Upload to Play Console**
   - Go to Google Play Console
   - Create new app or update existing
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Complete store listing information
   - Submit for review

## iOS Deployment

### Prerequisites

- macOS machine
- Xcode 15+
- Apple Developer account
- iOS device or simulator

### Build Configuration

1. **Update iOS deployment target**
   ```bash
   # In ios/Podfile
   platform :ios, '12.0'
   ```

2. **Configure signing in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Select Runner target
   - Go to Signing & Capabilities
   - Select your team
   - Configure bundle identifier

### Build Commands

```bash
# Clean build
flutter clean
flutter pub get

# Build for iOS
flutter build ios --release

# Build IPA (requires Mac)
flutter build ipa --release
```

### App Store Deployment

1. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace`
   - Select "Any iOS Device" as destination
   - Product → Archive
   - Upload to App Store Connect

2. **App Store Connect**
   - Complete app information
   - Submit for review

## Web Deployment

### Build Configuration

1. **Update web/index.html**
   ```html
   <base href="/">
   <title>Complaints Manager</title>
   ```

2. **Configure Firebase hosting**
   ```json
   // firebase.json
   {
     "hosting": {
       "public": "build/web",
       "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
       "rewrites": [{
         "source": "**",
         "destination": "/index.html"
       }]
     }
   }
   ```

### Build Commands

```bash
# Build for web
flutter build web --release

# Serve locally
flutter run -d chrome

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Custom Domain Setup

1. **Add custom domain in Firebase Console**
2. **Update DNS records**
3. **SSL certificate (automatic with Firebase)**

## CI/CD Pipeline

### GitHub Actions Example

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.1'
      - run: flutter pub get
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-bundle
          path: build/app/outputs/bundle/release/

  build-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build web --release
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: your-project-id
```

## Environment-Specific Configuration

### Development
```yaml
# config/dev.yaml
environment: development
api_url: https://dev-api.complaints.com
firebase_config:
  project_id: complaints-dev
  app_id: dev-app-id
```

### Production
```yaml
# config/prod.yaml
environment: production
api_url: https://api.complaints.com
firebase_config:
  project_id: complaints-prod
  app_id: prod-app-id
```

## Monitoring and Analytics

### Firebase Analytics
```dart
// Add to main.dart
await FirebaseAnalytics.instance.logAppOpen();
```

### Crashlytics
```dart
// Add to main.dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
```

### Performance Monitoring
```dart
// Track performance
final trace = FirebasePerformance.instance.newTrace('app_startup');
await trace.start();
// ... app initialization
await trace.stop();
```

## Security Considerations

### API Keys and Secrets
- Use environment variables
- Never commit secrets to version control
- Use Firebase App Check for API protection
- Implement proper authentication flows

### App Security
```bash
# Enable code obfuscation
flutter build apk --obfuscate --split-debug-info=debug-info/

# Enable tree shaking
flutter build web --tree-shake-icons
```

## Rollback Strategy

### Quick Rollback
1. **Android**: Upload previous version to Play Store
2. **iOS**: Release previous version from App Store Connect
3. **Web**: Revert Firebase hosting deployment

### Database Rollback
1. Export current Firestore data
2. Restore from backup
3. Update security rules if needed

## Troubleshooting

### Common Issues

1. **Build Errors**
   ```bash
   flutter clean
   flutter pub get
   flutter pub deps
   ```

2. **Firebase Connection**
   - Check google-services.json/GoogleService-Info.plist
   - Verify Firebase project configuration
   - Check network connectivity

3. **Platform-Specific Issues**
   - Android: Check Gradle version compatibility
   - iOS: Verify Xcode and deployment target
   - Web: Check CORS configuration

### Debugging Tools

```bash
# Enable verbose logging
flutter run --verbose

# Analyze app size
flutter build apk --analyze-size

# Check dependencies
flutter pub deps
```

## Performance Optimization

### Build Optimization
```bash
# Optimize for size
flutter build apk --target-platform android-arm64 --split-per-abi

# Enable R8 (Android)
# Add to android/app/build.gradle
android {
    buildTypes {
        release {
            shrinkResources true
            minifyEnabled true
        }
    }
}
```

### Runtime Optimization
- Use const constructors
- Implement lazy loading
- Optimize image sizes
- Cache network requests

## Backup and Recovery

### Automated Backups
```bash
# Firebase backup
gcloud firestore export gs://your-bucket-name

# Schedule with cron
0 2 * * * gcloud firestore export gs://backup-bucket/$(date +\%Y-\%m-\%d)
```

### Recovery Process
1. Stop application traffic
2. Restore database from backup
3. Verify data integrity
4. Resume application traffic
5. Monitor for issues

## Support and Maintenance

### Monitoring Checklist
- [ ] Application performance metrics
- [ ] Error rates and crash reports
- [ ] Database performance
- [ ] User feedback and reviews
- [ ] Security alerts

### Regular Maintenance
- Update dependencies monthly
- Review and update security rules
- Monitor Firebase quotas and usage
- Backup critical data regularly
- Test disaster recovery procedures