import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Web-specific file operations
class PlatformFile {
  static Future<Uint8List> readAsBytes(String path) async {
    throw UnsupportedError('File operations not available on web - use bytes directly');
  }
}