import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isOutlined;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.child,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = backgroundColor ?? const Color(0xFF253b74);
    final onPrimaryColor = textColor ?? Colors.white;

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 48,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: child ?? _buildButtonContent(primaryColor),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: child ?? _buildButtonContent(onPrimaryColor),
      ),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
    );
  }
}
