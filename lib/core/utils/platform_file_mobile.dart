import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Mobile-specific file operations
class PlatformFile {
  static Future<Uint8List> readAsBytes(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }
}