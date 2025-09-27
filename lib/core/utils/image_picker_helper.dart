import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import '../constants/strings.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<File?> pickImageFromGallery(BuildContext context) async {
    try {
      // Check permission
      final hasPermission = await _checkStoragePermission(context);
      if (!hasPermission) {
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);

        // Validate image
        final validationError = await _validateImage(file);
        if (validationError != null) {
          _showErrorDialog(context, validationError);
          return null;
        }

        return file;
      }

      return null;
    } catch (e) {
      _showErrorDialog(context, 'Failed to pick image from gallery');
      return null;
    }
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera(BuildContext context) async {
    try {
      // Check permission
      final hasPermission = await _checkCameraPermission(context);
      if (!hasPermission) {
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);

        // Validate image
        final validationError = await _validateImage(file);
        if (validationError != null) {
          _showErrorDialog(context, validationError);
          return null;
        }

        return file;
      }

      return null;
    } catch (e) {
      _showErrorDialog(context, 'Failed to capture image from camera');
      return null;
    }
  }

  // Show image picker options dialog
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickImageFromGallery(context);
                  if (file != null) {
                    Navigator.of(context).pop(file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickImageFromCamera(context);
                  if (file != null) {
                    Navigator.of(context).pop(file);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Check camera permission
  static Future<bool> _checkCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isDenied) {
        _showPermissionDialog(context, AppStrings.cameraPermission);
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(context, AppStrings.cameraPermission);
      return false;
    }

    return true;
  }

  // Check storage permission
  static Future<bool> _checkStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;

      if (status.isDenied) {
        final result = await Permission.storage.request();
        if (result.isDenied) {
          _showPermissionDialog(context, AppStrings.storagePermission);
          return false;
        }
      }

      if (status.isPermanentlyDenied) {
        _showPermissionDialog(context, AppStrings.storagePermission);
        return false;
      }
    }

    return true;
  }

  // Validate image file
  static Future<String?> _validateImage(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return 'Selected file does not exist';
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > AppConstants.maxImageSizeBytes) {
        return AppStrings.imageTooLarge;
      }

      // Check file extension
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      if (!AppConstants.allowedImageTypes.contains(extension)) {
        return AppStrings.invalidImageType;
      }

      return null;
    } catch (e) {
      return 'Failed to validate image file';
    }
  }

  // Show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show permission dialog
  static void _showPermissionDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(permission),
          content: const Text(AppStrings.permissionRequired),
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
              child: const Text(AppStrings.grantPermission),
            ),
          ],
        );
      },
    );
  }

  // Get file size in readable format
  static String getFileSizeString(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Get image dimensions
  static Future<Size?> getImageDimensions(File imageFile) async {
    try {
      final image = await decodeImageFromList(await imageFile.readAsBytes());
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      return null;
    }
  }

  // Compress image quality
  static Future<File?> compressImage(File imageFile, {int quality = 85}) async {
    try {
      final XFile? compressedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );

      if (compressedImage != null) {
        return File(compressedImage.path);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete temporary image file
  static Future<void> deleteTempImage(File? imageFile) async {
    try {
      if (imageFile != null && await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      // Ignore deletion errors
    }
  }
}
