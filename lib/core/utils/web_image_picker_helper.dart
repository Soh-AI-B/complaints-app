import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../constants/strings.dart';

class WebImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery - works on both web and mobile
  static Future<Uint8List?> pickImageFromGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        // Validate image
        final validationError = await _validateImage(bytes, image.name);
        if (validationError != null) {
          if (!context.mounted) return null;
          _showErrorDialog(context, validationError);
          return null;
        }

        return bytes;
      }

      return null;
    } catch (e) {
      if (!context.mounted) return null;
      _showErrorDialog(context, 'Failed to pick image from gallery');
      return null;
    }
  }

  // Pick image from camera - works on mobile, shows error on web
  static Future<Uint8List?> pickImageFromCamera(BuildContext context) async {
    if (kIsWeb) {
      _showErrorDialog(
        context,
        'Camera is not available on web. Please use gallery to select images.',
      );
      return null;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        // Validate image
        final validationError = await _validateImage(bytes, image.name);
        if (validationError != null) {
          if (!context.mounted) return null;
          _showErrorDialog(context, validationError);
          return null;
        }

        return bytes;
      }

      return null;
    } catch (e) {
      if (!context.mounted) return null;
      _showErrorDialog(context, 'Failed to capture image from camera');
      return null;
    }
  }

  // Show image picker options dialog - adapted for web
  static Future<Uint8List?> showImagePickerDialog(BuildContext context) async {
    return showDialog<Uint8List?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  final bytes = await pickImageFromGallery(dialogContext);
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop(bytes);
                },
              ),
              if (!kIsWeb) // Only show camera option on mobile
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    final bytes = await pickImageFromCamera(dialogContext);
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop(bytes);
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Validate image bytes
  static Future<String?> _validateImage(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      // Check file size
      if (bytes.length > AppConstants.maxImageSizeBytes) {
        return AppStrings.imageTooLarge;
      }

      // Check file extension
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

  // Get image dimensions from bytes
  static Future<Size?> getImageDimensions(Uint8List bytes) async {
    try {
      final image = await decodeImageFromList(bytes);
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      return null;
    }
  }

  // Public wrapper for validation (calls private _validateImage)
  static Future<String?> validateImage(Uint8List bytes, String fileName) async {
    return _validateImage(bytes, fileName);
  }

  // Public wrapper for showing error dialog
  static void showErrorDialog(BuildContext context, String message) {
    _showErrorDialog(context, message);
  }
}
