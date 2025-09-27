import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'platform_file_mobile.dart' if (dart.library.html) 'platform_file_web.dart';

// Platform-agnostic file representation
abstract class CrossFile {
  String get path;
  String get name;
  Future<Uint8List> readAsBytes();
  
  static CrossFile fromPath(String path) {
    if (kIsWeb) {
      return WebFile(path);
    } else {
      return MobileFile(path);
    }
  }
}

// Web implementation
class WebFile extends CrossFile {
  final String _path;
  final Uint8List? _bytes;
  
  WebFile(this._path, [this._bytes]);
  
  @override
  String get path => _path;
  
  @override
  String get name => _path.split('/').last;
  
  @override
  Future<Uint8List> readAsBytes() async {
    if (_bytes != null) return _bytes;
    throw UnsupportedError('Cannot read bytes from web file path without data');
  }
  
  WebFile copyWith({Uint8List? bytes}) {
    return WebFile(_path, bytes ?? _bytes);
  }
}

// Mobile implementation
class MobileFile extends CrossFile {
  final String _path;
  
  MobileFile(this._path);
  
  @override
  String get path => _path;
  
  @override
  String get name => _path.split('/').last;
  
  @override
  Future<Uint8List> readAsBytes() async {
    return await PlatformFile.readAsBytes(_path);
  }
}

// Helper to create CrossFile from image picker results
CrossFile createCrossFileFromImagePicker(String path, {Uint8List? bytes}) {
  if (kIsWeb && bytes != null) {
    return WebFile(path, bytes);
  } else {
    return MobileFile(path);
  }
}