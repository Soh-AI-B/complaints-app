import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? const Color(0xFF253b74),
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 2,
      shadowColor: (backgroundColor ?? const Color(0xFF253b74)).withOpacity(
        0.3,
      ),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
