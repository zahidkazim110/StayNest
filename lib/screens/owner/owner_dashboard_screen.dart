import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/owner_hostel.dart';
import 'owner_analytics_screen.dart';
import 'owner_hostel_screens.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late Future<List<OwnerHostel>> _hostelsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _hostelsFuture = OwnerHostelStorage.getHostels();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Owner Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Owner profile',
            onPressed: () => _open(const OwnerProfileScreen()),
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 7),
        ],
      ),
      body: FutureBuilder<List<OwnerHostel>>(
        future: _hostelsFuture,
        builder: (context, snapshot) {
          final hostels = snapshot.data ?? const <OwnerHostel>[];
          final rooms = hostels.fold<int>(0, (sum, h) => sum + h.rooms.length);
          final beds = hostels.fold<int>(0, (sum, h) =>
            sum + h.rooms.fold<int>(0, (roomSum, r) => roomSum + r.capacity));
          final available = hostels.fold<int>(0, (sum, h) =>
            sum + h.rooms.fold<int>(0, (roomSum, r) => roomSum + r.availableBeds));
          final occupied = beds - available;

          return RefreshIndicator(
            onRefresh: () async => setState(_load),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                const Text('Welcome back!', style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('Your property management workspace',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Your properties', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(height: 6),
                      Text('Manage your hostels\nfrom one place',
                        style: TextStyle(color: Colors.white, fontSize: 19, height: 1.25, fontWeight: FontWeight.bold)),
                    ])),
                    Container(padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), shape: BoxShape.circle),
                      child: const Icon(Icons.apartment_rounded, size: 31, color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 23),
                const _SectionTitle('Property overview'),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(padding: EdgeInsets.all(25), child: Center(child: CircularProgressIndicator()))
                else
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 11, mainAxisSpacing: 11, childAspectRatio: 1.55,
                    children: [
                      _StatCard(title: 'My hostels', value: hostels.length.toString(), icon: Icons.apartment_rounded),
                      _StatCard(title: 'Rooms listed', value: rooms.toString(), icon: Icons.meeting_room_rounded),
                      _StatCard(title: 'Occupied beds', value: occupied.toString(), icon: Icons.people_alt_rounded),
                      _StatCard(title: 'Available beds', value: available.toString(), icon: Icons.bed_outlined),
                    ],
                  ),
                const SizedBox(height: 24),
                const _SectionTitle('Quick actions'),
                const SizedBox(height: 11),
                _ActionTile(
                  icon: Icons.add_home_work_rounded, title: 'Add New Hostel',
                  subtitle: 'Create a listing with Google Maps location',
                  onTap: () => _open(const AddHostelScreen()), prominent: true),
                _ActionTile(
                  icon: Icons.apartment_rounded, title: 'My Hostels',
                  subtitle: 'View, update and manage your listings',
                  onTap: () => _open(const OwnerHostelsScreen())),
                _ActionTile(
                  icon: Icons.meeting_room_rounded, title: 'Manage Rooms',
                  subtitle: 'Set room types, rent and bed availability',
                  onTap: () => _open(const OwnerHostelsScreen())),
                _ActionTile(
                  icon: Icons.event_available_rounded, title: 'Booking Requests',
                  subtitle: 'Review incoming student enquiries',
                  onTap: () => _open(const OwnerBookingsScreen())),
                _ActionTile(
                  icon: Icons.analytics_outlined, title: 'Hostel Analytics',
                  subtitle: 'View occupancy and performance insights',
                  onTap: () => _open(const OwnerAnalyticsScreen())),
                _ActionTile(
                  icon: Icons.person_outline_rounded, title: 'Owner Profile',
                  subtitle: 'Update your contact information',
                  onTap: () => _open(const OwnerProfileScreen())),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(15)),
                  child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 19),
                    SizedBox(width: 9),
                    Expanded(child: Text(
                      'Your listings and room details are saved on this device for now. Connect the StayNest backend to publish them to students and receive live bookings.',
                      style: TextStyle(fontSize: 11, height: 1.45, color: AppColors.textSecondary))),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: AppColors.primary, size: 22),
      const SizedBox(height: 7),
      Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool prominent;
  const _ActionTile({required this.icon, required this.title, required this.subtitle,
    required this.onTap, this.prominent = false});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: prominent ? AppColors.primaryLight : Colors.white,
      borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary, size: 25),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
    ),
  );
}
