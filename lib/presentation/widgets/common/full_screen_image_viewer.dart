import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const FullScreenImageViewer({super.key, required this.imageUrl, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title ?? 'Task Image',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, String imageUrl, {String? title}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImageViewer(imageUrl: imageUrl, title: title),
      ),
    );
  }
}
