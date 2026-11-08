import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  static const _notificationsKey = 'staynest_setting_notifications';
  static const _tipsKey = 'staynest_setting_tips';
  static const _languageKey = 'staynest_setting_language';

  bool notifications = true;
  bool recommendationTips = true;
  String language = 'English';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      notifications = prefs.getBool(_notificationsKey) ?? true;
      recommendationTips = prefs.getBool(_tipsKey) ?? true;
      language = prefs.getString(_languageKey) ?? 'English';
      loading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
    if (!mounted) return;
    setState(() => language = value);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preference saved. Language switching across the app is not connected yet.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Preferences', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _card([
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: const Text('Notifications'),
              subtitle: const Text('Enable in-app notification preferences'),
              value: notifications,
              onChanged: (value) {
                setState(() => notifications = value);
                _saveBool(_notificationsKey, value);
              },
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: const Text('Recommendation tips'),
              subtitle: const Text('Show helpful hostel discovery suggestions'),
              value: recommendationTips,
              onChanged: (value) {
                setState(() => recommendationTips = value);
                _saveBool(_tipsKey, value);
              },
            ),
          ]),
          const SizedBox(height: 22),
          const Text('Language', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _card([
            RadioGroup<String>(
              groupValue: language,
              onChanged: (value) {
                if (value != null) {
                  _saveLanguage(value);
                }
              },
              child: const Column(
                children: [
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('English'),
                    value: 'English',
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Urdu'),
                    value: 'Urdu',
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 22),
          const Text('Privacy & security', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _card(const [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.lock_outline_rounded, color: AppColors.primary),
              title: Text('Your profile data'),
              subtitle: Text('Profile information is stored locally on this device in the current demo.'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
    child: Column(children: children),
  );
}
