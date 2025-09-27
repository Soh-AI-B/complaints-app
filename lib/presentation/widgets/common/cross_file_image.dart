import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../../core/utils/file_helper.dart';

/// A widget that displays images from CrossFile objects, supporting both mobile and web platforms
class CrossFileImage extends StatelessWidget {
  final CrossFile crossFile;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Widget? errorWidget;

  const CrossFileImage({
    Key? key,
    required this.crossFile,
    this.fit,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // For web, we need to use Image.memory with bytes
      return FutureBuilder<Uint8List>(
        future: crossFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorWidget ?? 
                Container(
                  width: width,
                  height: height,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.red),
                );
          }
          
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: fit,
              width: width,
              height: height,
              alignment: alignment,
              errorBuilder: (context, error, stackTrace) {
                return errorWidget ?? 
                    Container(
                      width: width,
                      height: height,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    );
              },
            );
          }
          
          // Loading state
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    } else {
      // For mobile, we can use Image.file directly
      return Image.file(
        File(crossFile.path),
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? 
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.red),
              );
        },
      );
    }
  }
}