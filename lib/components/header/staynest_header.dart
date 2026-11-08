import 'package:flutter/material.dart';

class StayNestHeader extends StatelessWidget {
  final bool dark;
  final bool showBrand;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const StayNestHeader({
    super.key,
    this.dark = false,
    this.showBrand = true,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : const Color(0xFF172B2A);
    final tileColor = dark
        ? const Color(0xFF21433F)
        : const Color(0xFFE1F3EF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (showBrand) ...[
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087F75), Color(0xFF087F75)],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.home_work_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'StayNest',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Student Living',
                    style: TextStyle(
                      color: foreground.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const Spacer(),
          _actionIcon(
            icon: Icons.notifications_none_rounded,
            color: foreground,
            background: tileColor,
            onTap: onNotificationTap ??
                () => _showMessage(context, 'Notifications coming soon.'),
          ),
          const SizedBox(width: 9),
          _actionIcon(
            icon: Icons.person_outline_rounded,
            color: foreground,
            background: tileColor,
            onTap: onProfileTap ??
                () => _showMessage(context, 'Profile coming soon.'),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onTap,
  }) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 21),
        tooltip: icon == Icons.notifications_none_rounded
            ? 'Notifications'
            : 'Profile',
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
