import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../constants/strings.dart';
import 'image_picker_helper.dart';
import 'web_image_picker_helper.dart';

class UnifiedImagePicker {
  // Unified method that works on all platforms
  static Future<Uint8List?> pickImage(BuildContext context) async {
    return showImagePickerDialog(context);
  }

  // Show image picker dialog - chooses appropriate implementation
  static Future<Uint8List?> showImagePickerDialog(BuildContext context) async {
    if (kIsWeb) {
      return WebImagePickerHelper.showImagePickerDialog(context);
    } else {
      // For mobile, convert File to Uint8List
      final file = await ImagePickerHelper.showImagePickerDialog(context);
      if (file != null) {
        return file.readAsBytes();
      }
      return null;
    }
  }

  // Pick from gallery - chooses appropriate implementation
  static Future<Uint8List?> pickImageFromGallery(BuildContext context) async {
    if (kIsWeb) {
      return WebImagePickerHelper.pickImageFromGallery(context);
    } else {
      final file = await ImagePickerHelper.pickImageFromGallery(context);
      if (file != null) {
        return file.readAsBytes();
      }
      return null;
    }
  }

  // Pick from camera - only available on mobile
  static Future<Uint8List?> pickImageFromCamera(BuildContext context) async {
    if (kIsWeb) {
      WebImagePickerHelper.showErrorDialog(
        context,
        'Camera is not available on web. Please use gallery to select images.',
      );
      return null;
    } else {
      final file = await ImagePickerHelper.pickImageFromCamera(context);
      if (file != null) {
        return file.readAsBytes();
      }
      return null;
    }
  }

  // Validate image bytes
  static Future<String?> validateImage(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      return WebImagePickerHelper.validateImage(bytes, fileName);
    } else {
      // For mobile, do basic validation
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
  }

  // Get file size string
  static String getFileSizeString(int bytes) {
    return WebImagePickerHelper.getFileSizeString(bytes);
  }

  // Get image dimensions
  static Future<Size?> getImageDimensions(Uint8List bytes) async {
    return WebImagePickerHelper.getImageDimensions(bytes);
  }
}
