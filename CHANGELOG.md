# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Web platform support
- Dark theme support (planned)
- Export functionality (planned)

### Changed
- Improved UI responsiveness
- Enhanced notification system

### Fixed
- Category selection bug in user management
- Task filtering for managers

## [1.0.0] - 2025-01-27

### Added
- Initial release of Complaints Manager
- Role-based authentication (Employee, Manager, Admin)
- Task management with categories and priorities
- Real-time notifications
- Analytics dashboard
- User management system
- Category-specific manager assignments
- Image upload functionality
- Offline support
- Firebase integration
- Clean Architecture implementation
- BLoC state management
- Comprehensive testing suite

### Features
- **Authentication System**
  - Firebase Auth integration
  - Role-based access control
  - Secure session management
  
- **Task Management**
  - Create, update, and track complaints
  - Image attachments
  - Priority levels (Urgent, High, Normal, Low)
  - Status tracking (Pending, In Progress, Completed, Cancelled)
  - Category organization
  
- **User Roles**
  - Employee: Submit and track complaints
  - Manager: Manage assigned category tasks
  - Admin: Full system administration
  
- **Real-time Features**
  - Push notifications
  - Live task updates
  - Notification badges
  
- **Analytics**
  - Task statistics
  - Performance metrics
  - Category-wise reporting
  
- **Technical Features**
  - Offline functionality
  - Image compression and upload
  - Responsive design
  - Cross-platform support (Android, iOS, Web)

### Architecture
- Clean Architecture pattern
- BLoC for state management
- Dependency injection with GetIt
- Repository pattern
- Use cases for business logic
- Firebase as backend service

### Dependencies
- Flutter 3.8.1+
- Dart 3.8.1+
- Firebase services (Auth, Firestore, Storage, Messaging)
- BLoC for state management
- GetIt for dependency injection
- Image picker and caching
- Charts for analytics
- Local notifications

## [0.1.0] - 2024-12-15

### Added
- Project setup and initial structure
- Basic authentication flow
- Task creation functionality
- Firebase configuration
- Initial UI components

---

## Types of Changes

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes