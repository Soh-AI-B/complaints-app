import 'dart:io';
import 'dart:convert';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static const String _cloudName =
      'dwkblixgf'; // Replace with your Cloudinary cloud name
  static const String _uploadPreset =
      'complaints_preset'; // Replace with your upload preset

  // TODO: Add these credentials securely (e.g., from environment variables)
  // You need to get these from your Cloudinary dashboard:
  // 1. Go to https://cloudinary.com/console
  // 2. Navigate to Settings > API Keys
  // 3. Copy your API Key and API Secret
  static const String _apiKey =
      '234396831434842'; // Replace with your real API key
  static const String _apiSecret =
      'ryrW8MusluJqB_IXTwtYIGgKpMY'; // Replace with your real API secret

  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset);
  }

  /// Upload image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage({
    required File imageFile,
    required String fileName,
    String? folder,
  }) async {
    try {
      final result = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder ?? 'complaints',
          publicId: fileName,
        ),
      );

      return result.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload image with transformations for optimization
  /// Automatically resizes and compresses images
  Future<String> uploadOptimizedImage({
    required File imageFile,
    required String fileName,
    String? folder,
    int maxWidth = 1200,
    int quality = 80,
  }) async {
    try {
      // For optimization, we'll upload normally and use URL transformations
      final result = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder ?? 'complaints',
          publicId: fileName,
        ),
      );

      // Return optimized URL
      return getOptimizedUrl(
        result.secureUrl,
        width: maxWidth,
        quality: quality,
        format: 'auto',
      );
    } catch (e) {
      throw Exception('Failed to upload optimized image: $e');
    }
  }

  /// Delete image from Cloudinary using public ID
  /// Returns true if deletion was successful
  Future<bool> deleteImage(String publicId) async {
    try {
      print('🗑️ Attempting to delete image with public ID: $publicId');

      // Check if credentials are configured
      if (_apiKey == 'YOUR_ACTUAL_API_KEY' ||
          _apiSecret == 'YOUR_ACTUAL_API_SECRET') {
        print(
          '🗑️ ⚠️ Cloudinary API credentials not configured - skipping image deletion',
        );
        print(
          '🗑️ ⚠️ Please update _apiKey and _apiSecret in CloudinaryService',
        );
        return true; // Don't fail the task deletion because of missing credentials
      }

      // Create timestamp for signature
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create signature using SHA1 hash
      final signaturePayload =
          'public_id=$publicId&timestamp=$timestamp$_apiSecret';
      final signature = sha1.convert(utf8.encode(signaturePayload)).toString();

      // Create request URL
      final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy';

      // Create request body
      final body = {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
        'api_key': _apiKey,
        'signature': signature,
      };

      print('🗑️ Making deletion request to Cloudinary...');

      // Make the DELETE request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      print('🗑️ Response status: ${response.statusCode}');
      print('🗑️ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final result = responseData['result'] as String?;

        if (result == 'ok') {
          print('🗑️ ✅ Image deleted successfully from Cloudinary');
          return true;
        } else if (result == 'not found') {
          print(
            '🗑️ ⚠️ Image not found in Cloudinary (may have been deleted already)',
          );
          return true; // Consider this a success since the image is not there
        } else {
          print('🗑️ ❌ Unexpected result from Cloudinary: $result');
          return false;
        }
      } else if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['error']?['message'] ?? 'Unauthorized';
        print('🗑️ ❌ Authentication failed: $errorMessage');
        print('🗑️ ❌ Please check your Cloudinary API key and secret');
        return false;
      } else if (response.statusCode == 404) {
        print(
          '🗑️ ⚠️ Image not found in Cloudinary (404) - considering this a success',
        );
        return true; // Image doesn't exist, so deletion is technically successful
      } else {
        print(
          '🗑️ ❌ Failed to delete image. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('🗑️ ❌ Exception during image deletion: $e');
      return false;
    }
  }

  /// Extract public ID from Cloudinary URL
  /// Used for deletion operations
  String extractPublicId(String cloudinaryUrl) {
    final uri = Uri.parse(cloudinaryUrl);
    final pathSegments = uri.pathSegments;

    // Find the index of 'upload' in the path
    final uploadIndex = pathSegments.indexOf('upload');
    if (uploadIndex == -1 || uploadIndex + 2 >= pathSegments.length) {
      throw Exception('Invalid Cloudinary URL format');
    }

    // The public ID is everything after the version number
    final publicIdWithExtension = pathSegments
        .sublist(uploadIndex + 2)
        .join('/');

    // Remove file extension
    final lastDotIndex = publicIdWithExtension.lastIndexOf('.');
    if (lastDotIndex != -1) {
      return publicIdWithExtension.substring(0, lastDotIndex);
    }

    return publicIdWithExtension;
  }

  /// Generate optimized URL for existing image
  /// Useful for displaying thumbnails
  String getOptimizedUrl(
    String originalUrl, {
    int? width,
    int? height,
    int? quality,
    String? format,
  }) {
    try {
      final publicId = extractPublicId(originalUrl);

      String transformationString = '';
      final transformations = <String>[];

      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      if (quality != null) transformations.add('q_$quality');
      if (format != null) transformations.add('f_$format');

      if (transformations.isNotEmpty) {
        transformationString = '/${transformations.join(',')}/';
      }

      return 'https://res.cloudinary.com/$_cloudName/image/upload$transformationString$publicId';
    } catch (e) {
      // If URL parsing fails, return original URL
      return originalUrl;
    }
  }

  /// Get thumbnail URL (small size for lists)
  String getThumbnailUrl(String originalUrl) {
    return getOptimizedUrl(
      originalUrl,
      width: 300,
      height: 200,
      quality: 70,
      format: 'auto',
    );
  }

  /// Get preview URL (medium size for details)
  String getPreviewUrl(String originalUrl) {
    return getOptimizedUrl(
      originalUrl,
      width: 800,
      height: 600,
      quality: 85,
      format: 'auto',
    );
  }
}
