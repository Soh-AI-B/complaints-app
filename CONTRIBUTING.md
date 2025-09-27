# Contributing to Complaints Manager

First off, thank you for considering contributing to Complaints Manager! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1+)
- Dart SDK (3.8.1+)
- Git
- Firebase account
- IDE (VS Code, Android Studio, or IntelliJ)

### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/your-username/complaints-manager.git
   cd complaints-manager
   ```

2. **Set up development environment**
   ```bash
   flutter pub get
   flutter pub run build_runner build
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Add your configuration files
   - Set up authentication and Firestore

4. **Run the app**
   ```bash
   flutter run
   ```

## How to Contribute

### Types of Contributions

We welcome several types of contributions:

- 🐛 **Bug fixes**
- ✨ **New features**
- 📚 **Documentation improvements**
- 🧪 **Tests**
- 🎨 **UI/UX improvements**
- 🔧 **Code refactoring**

### Development Workflow

1. **Check existing issues** - Look for existing issues or create a new one
2. **Fork and branch** - Create a feature branch from `main`
3. **Make changes** - Follow our coding standards
4. **Test thoroughly** - Add tests for new functionality
5. **Submit PR** - Create a pull request with clear description

## Pull Request Process

1. **Branch naming convention**
   ```
   feature/add-new-dashboard
   bugfix/fix-authentication-issue
   docs/update-readme
   refactor/improve-bloc-structure
   ```

2. **Commit message format**
   ```
   feat: add user profile management
   fix: resolve login authentication bug
   docs: update API documentation
   style: format code according to style guide
   refactor: improve state management structure
   test: add unit tests for user service
   ```

3. **Pull request checklist**
   - [ ] Code follows the style guidelines
   - [ ] Self-review of code completed
   - [ ] Tests added for new functionality
   - [ ] Documentation updated if needed
   - [ ] No breaking changes (or clearly documented)
   - [ ] All tests pass
   - [ ] Screenshots added for UI changes

4. **PR template**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Code refactoring

   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Manual testing completed
   - [ ] All tests pass

   ## Screenshots (if applicable)
   Add screenshots for UI changes
   ```

## Coding Standards

### Dart/Flutter Guidelines

1. **Follow Dart style guide**
   ```bash
   flutter analyze
   dart format .
   ```

2. **Architecture patterns**
   - Use Clean Architecture
   - Follow BLoC pattern for state management
   - Implement proper dependency injection

3. **File naming**
   ```
   snake_case for files: user_profile_page.dart
   PascalCase for classes: UserProfilePage
   camelCase for variables: userName
   UPPER_CASE for constants: MAX_RETRY_ATTEMPTS
   ```

4. **Code organization**
   ```dart
   // 1. Dart imports
   import 'dart:async';
   
   // 2. Flutter imports
   import 'package:flutter/material.dart';
   
   // 3. Package imports
   import 'package:flutter_bloc/flutter_bloc.dart';
   
   // 4. Project imports
   import '../widgets/custom_button.dart';
   ```

### Documentation

1. **Class documentation**
   ```dart
   /// Manages user authentication and profile data.
   /// 
   /// This service handles login, logout, and profile updates.
   /// It integrates with Firebase Auth and Firestore.
   class AuthService {
     // Implementation
   }
   ```

2. **Method documentation**
   ```dart
   /// Authenticates user with email and password.
   /// 
   /// Returns [User] on success or throws [AuthException] on failure.
   /// 
   /// Example:
   /// ```dart
   /// final user = await authService.login('user@example.com', 'password');
   /// ```
   Future<User> login(String email, String password) async {
     // Implementation
   }
   ```

## Testing Guidelines

### Test Structure

```
test/
├── unit/
│   ├── blocs/
│   ├── services/
│   └── repositories/
├── widget/
│   └── pages/
└── integration/
    └── app_test.dart
```

### Writing Tests

1. **Unit tests**
   ```dart
   group('AuthBloc', () {
     test('emits authenticated state on successful login', () async {
       // Arrange
       when(mockAuthService.login(any, any))
           .thenAnswer((_) async => mockUser);
       
       // Act
       authBloc.add(LoginRequested(email, password));
       
       // Assert
       expectLater(authBloc.stream, emits(AuthAuthenticated(mockUser)));
     });
   });
   ```

2. **Widget tests**
   ```dart
   testWidgets('displays login form', (WidgetTester tester) async {
     await tester.pumpWidget(MaterialApp(home: LoginPage()));
     
     expect(find.byType(TextFormField), findsNWidgets(2));
     expect(find.text('Login'), findsOneWidget);
   });
   ```

### Test Requirements

- Unit tests for all business logic
- Widget tests for complex UI components
- Integration tests for critical user flows
- Minimum 80% code coverage

## Reporting Bugs

### Before Submitting a Bug Report

1. Check if the bug has already been reported
2. Try to reproduce the bug
3. Gather relevant information

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Go to...
2. Click on...
3. See error...

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Device: [e.g. iPhone 12, Pixel 5]
- OS: [e.g. iOS 15, Android 11]
- App Version: [e.g. 1.0.0]

## Screenshots
If applicable, add screenshots

## Additional Context
Any other relevant information
```

## Feature Requests

### Before Submitting

1. Check if the feature has been requested
2. Consider if it fits the project scope
3. Think about implementation complexity

### Feature Request Template

```markdown
## Feature Description
Clear description of the proposed feature

## Problem Statement
What problem does this solve?

## Proposed Solution
How should this work?

## Alternatives Considered
Other solutions you've thought about

## Additional Context
Mockups, examples, or references
```

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Special thanks in documentation

## Questions?

Feel free to reach out:
- Create an issue with the "question" label
- Contact maintainers directly
- Join our community discussions

Thank you for contributing! 🚀