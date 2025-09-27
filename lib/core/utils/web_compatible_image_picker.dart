import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import '../constants/strings.dart';
import './file_helper.dart';

class WebCompatibleImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery - web compatible
  static Future<CrossFile?> pickImageFromGallery(BuildContext context) async {
    try {
      // On web, permissions are handled by browser
      if (!kIsWeb) {
        final hasPermission = await _checkStoragePermission(context);
        if (!hasPermission) {
          return null;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // On web, read bytes directly
          final bytes = await image.readAsBytes();
          return WebFile(image.path, bytes);
        } else {
          // On mobile, use file path
          return MobileFile(image.path);
        }
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to pick image: ${e.toString()}');
      }
      return null;
    }
  }

  // Pick image from camera - web compatible
  static Future<CrossFile?> pickImageFromCamera(BuildContext context) async {
    try {
      // On web, camera access is handled by browser
      if (!kIsWeb) {
        final hasPermission = await _checkCameraPermission(context);
        if (!hasPermission) {
          return null;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // On web, read bytes directly
          final bytes = await image.readAsBytes();
          return WebFile(image.path, bytes);
        } else {
          // On mobile, use file path
          return MobileFile(image.path);
        }
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to capture image: ${e.toString()}');
      }
      return null;
    }
  }

  // Pick multiple images - web compatible
  static Future<List<CrossFile>> pickMultipleImages(BuildContext context) async {
    try {
      // On web, permissions are handled by browser
      if (!kIsWeb) {
        final hasPermission = await _checkStoragePermission(context);
        if (!hasPermission) {
          return [];
        }
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      List<CrossFile> crossFiles = [];
      
      for (XFile image in images) {
        if (kIsWeb) {
          // On web, read bytes directly
          final bytes = await image.readAsBytes();
          crossFiles.add(WebFile(image.path, bytes));
        } else {
          // On mobile, use file path
          crossFiles.add(MobileFile(image.path));
        }
      }

      return crossFiles;
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to pick images: ${e.toString()}');
      }
      return [];
    }
  }

  // Show image source selection dialog
  static Future<CrossFile?> showImageSourceDialog(BuildContext context) async {
    return await showDialog<CrossFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await pickImageFromGallery(context);
                Navigator.of(context).pop(image);
              },
            ),
            // Only show camera option on mobile
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromCamera(context);
                  Navigator.of(context).pop(image);
                },
              ),
          ],
        ),
      ),
    );
  }

  // Validate image file
  static Future<String?> validateImage(CrossFile file) async {
    try {
      final bytes = await file.readAsBytes();
      
      // Check file size (max 5MB)
      if (bytes.length > AppConstants.maxImageSizeBytes) {
        return AppStrings.imageTooLarge;
      }

      // For web, we can't easily check file type from path
      // The image_picker package already validates image types
      
      return null; // No error
    } catch (e) {
      return 'Failed to validate image: ${e.toString()}';
    }
  }

  // Check storage permission (mobile only)
  static Future<bool> _checkStoragePermission(BuildContext context) async {
    if (kIsWeb) return true; // Web doesn't need explicit permissions
    
    var status = await Permission.storage.status;
    
    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Storage Permission Required',
          'This app needs storage access to select images. Please enable it in settings.',
        );
      }
      return false;
    }

    return status.isGranted;
  }

  // Check camera permission (mobile only)
  static Future<bool> _checkCameraPermission(BuildContext context) async {
    if (kIsWeb) return true; // Web handles camera access through browser
    
    var status = await Permission.camera.status;
    
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Camera Permission Required',
          'This app needs camera access to take photos. Please enable it in settings.',
        );
      }
      return false;
    }

    return status.isGranted;
  }

  // Show permission dialog
  static void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  // Show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}