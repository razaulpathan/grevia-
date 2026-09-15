import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AvatarView extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  final bool isOnline;
  final bool showOnlineIndicator;
  final VoidCallback? onTap;

  const AvatarView({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = 48,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.onTap,
  });

  String _getInitials(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return 'G';
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getInitialsBgColor(String input) {
    final colors = [
      AppColors.primaryGreen,
      AppColors.darkGreen,
      const Color(0xFF2E7D32),
      const Color(0xFF00897B),
      const Color(0xFF0097A7),
      const Color(0xFF0288D1),
      const Color(0xFF5E35B1),
      const Color(0xFF3949AB),
    ];
    final hash = input.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = photoUrl != null && photoUrl!.trim().isNotEmpty;

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasImage ? Colors.transparent : _getInitialsBgColor(name),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: !hasImage
          ? Text(
              _getInitials(name),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            )
          : null,
    );

    if (showOnlineIndicator) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: AppColors.onlineGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
