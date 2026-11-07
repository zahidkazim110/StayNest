import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';
import '../../models/hostel_activity_storage.dart';
import '../hostel_details/hostel_details_screen.dart';

class SavedHostelsScreen extends StatefulWidget {
  const SavedHostelsScreen({super.key});

  @override
  State<SavedHostelsScreen> createState() => _SavedHostelsScreenState();
}

class _SavedHostelsScreenState extends State<SavedHostelsScreen> {
  List<Hostel> _favorites = [];
  List<Hostel> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final favorites = await HostelActivityStorage.getFavorites();
    final recent = await HostelActivityStorage.getRecentlyViewed();

    if (!mounted) return;

    setState(() {
      _favorites = favorites;
      _recent = recent;
      _loading = false;
    });
  }

  Future<void> _openHostel(Hostel hostel) async {
    await HostelActivityStorage.addRecentlyViewed(hostel);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HostelDetailsScreen(hostel: hostel)),
    );

    if (mounted) _loadData();
  }

  Future<void> _removeFavorite(Hostel hostel) async {
    await HostelActivityStorage.removeFavorite(hostel);
    await _loadData();
  }

  Widget _sectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hostelTile(Hostel hostel, {required bool isFavorite}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            leading: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              hostel.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                '${hostel.area}\nPKR ${hostel.monthlyRent} / month',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            isThreeLine: true,
            trailing: isFavorite
                ? IconButton(
                    tooltip: 'Remove Favorite',
                    onPressed: () => _removeFavorite(hostel),
                    icon: const Icon(Icons.favorite, color: Colors.red),
                  )
                : const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
            onTap: () => _openHostel(hostel),
          ),
        ),
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Saved Hostels',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _sectionTitle('My Favorites', _favorites.length),
                  if (_favorites.isEmpty)
                    _emptyMessage(
                      'No favorite hostels yet. Tap the heart on a hostel to save it.',
                    )
                  else
                    ..._favorites.map(
                      (hostel) => _hostelTile(hostel, isFavorite: true),
                    ),
                  _sectionTitle('Recently Viewed', _recent.length),
                  if (_recent.isEmpty)
                    _emptyMessage('Hostels you view will appear here.')
                  else
                    ..._recent.map(
                      (hostel) => _hostelTile(hostel, isFavorite: false),
                    ),
                ],
              ),
            ),
    );
  }
}
