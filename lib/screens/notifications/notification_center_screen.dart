import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  static const String _readKey = 'staynest_demo_notification_read';
  static const String _dismissedKey = 'staynest_demo_notification_dismissed';

  static const List<_StayNestNotification> _notifications = [
    _StayNestNotification(
      id: 'welcome',
      title: 'Welcome to StayNest',
      message:
          'Your student accommodation journey starts here. Explore hostels and save the places you like.',
      time: 'Getting started',
      icon: Icons.waving_hand_rounded,
      color: AppColors.primary,
    ),
    _StayNestNotification(
      id: 'recommendations',
      title: 'Explore hostel recommendations',
      message:
          'Set your preferred city, room type and budget to see hostel suggestions that match your needs.',
      time: 'Explore StayNest',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.success,
    ),
    _StayNestNotification(
      id: 'profile',
      title: 'Complete your student profile',
      message:
          'Add your contact and university information to keep your demo booking details organized.',
      time: 'Profile tip',
      icon: Icons.person_rounded,
      color: AppColors.warning,
    ),
  ];

  Set<String> _readIds = {};
  Set<String> _dismissedIds = {};
  bool _loading = true;

  List<_StayNestNotification> get _visibleNotifications =>
      _notifications
          .where((item) => !_dismissedIds.contains(item.id))
          .toList();

  int get _unreadCount => _visibleNotifications
      .where((item) => !_readIds.contains(item.id))
      .length;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _readIds = preferences.getStringList(_readKey)?.toSet() ?? {};
      _dismissedIds =
          preferences.getStringList(_dismissedKey)?.toSet() ?? {};
      _loading = false;
    });
  }

  Future<void> _markRead(String id) async {
    final updated = {..._readIds, id};
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_readKey, updated.toList());
    if (!mounted) return;
    setState(() => _readIds = updated);
  }

  Future<void> _markAllRead() async {
    final updated = {
      ..._readIds,
      ..._visibleNotifications.map((item) => item.id),
    };
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_readKey, updated.toList());
    if (!mounted) return;
    setState(() => _readIds = updated);
  }

  Future<void> _dismiss(String id) async {
    final updated = {..._dismissedIds, id};
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_dismissedKey, updated.toList());
    if (!mounted) return;
    setState(() => _dismissedIds = updated);
  }

  Future<void> _restoreAll() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_readKey);
    await preferences.remove(_dismissedKey);
    if (!mounted) return;
    setState(() {
      _readIds = {};
      _dismissedIds = {};
    });
  }

  void _openNotification(_StayNestNotification notification) {
    _markRead(notification.id);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(notification.icon, color: notification.color, size: 30),
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : items.isEmpty
              ? _emptyState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_active_rounded,
                            color: AppColors.primary,
                            size: 25,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _unreadCount == 0
                                      ? 'You are all caught up'
                                      : '$_unreadCount unread notification(s)',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Your StayNest updates appear here.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'YOUR UPDATES',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...items.map(_notificationCard),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        onPressed: _restoreAll,
                        icon: const Icon(Icons.refresh_rounded, size: 17),
                        label: const Text('Restore demo notifications'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'These are local demo notifications. Live booking and server alerts are not connected.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _notificationCard(_StayNestNotification notification) {
    final isRead = _readIds.contains(notification.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _openNotification(notification),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: notification.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(notification.icon, color: notification.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight:
                                  isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      notification.time,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Dismiss notification',
                onPressed: () => _dismiss(notification.id),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'You have dismissed all demo notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _restoreAll,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Restore notifications'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StayNestNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;

  const _StayNestNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });
}
