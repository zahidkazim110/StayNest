import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/owner_hostel.dart';

class OwnerAnalyticsScreen extends StatefulWidget {
  const OwnerAnalyticsScreen({super.key});

  @override
  State<OwnerAnalyticsScreen> createState() => _OwnerAnalyticsScreenState();
}

class _OwnerAnalyticsScreenState extends State<OwnerAnalyticsScreen> {
  late Future<List<OwnerHostel>> _hostelsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _hostelsFuture = OwnerHostelStorage.getHostels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Hostel Analytics')),
      body: FutureBuilder<List<OwnerHostel>>(
        future: _hostelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final hostels = snapshot.data ?? const <OwnerHostel>[];
          final roomCount = hostels.fold<int>(0, (sum, h) => sum + h.rooms.length);
          final totalBeds = hostels.fold<int>(0, (sum, h) =>
            sum + h.rooms.fold<int>(0, (roomSum, r) => roomSum + r.capacity));
          final availableBeds = hostels.fold<int>(0, (sum, h) =>
            sum + h.rooms.fold<int>(0, (roomSum, r) => roomSum + r.availableBeds));
          final occupiedBeds = totalBeds - availableBeds;
          final occupancy = totalBeds == 0 ? 0.0 : occupiedBeds / totalBeds;
          final monthlyEstimate = hostels.fold<int>(0, (sum, h) =>
            sum + h.rooms.fold<int>(0, (roomSum, r) =>
              roomSum + (r.capacity - r.availableBeds) * r.monthlyRent));

          return RefreshIndicator(
            onRefresh: () async => setState(_load),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Your property performance',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 5),
                const Text('Calculated from the hostel and room information saved on this device.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.45,
                  children: [
                    _MetricCard(title: 'Hostels', value: hostels.length.toString(), icon: Icons.apartment_rounded),
                    _MetricCard(title: 'Rooms', value: roomCount.toString(), icon: Icons.meeting_room_rounded),
                    _MetricCard(title: 'Occupied beds', value: occupiedBeds.toString(), icon: Icons.people_alt_rounded),
                    _MetricCard(title: 'Available beds', value: availableBeds.toString(), icon: Icons.bed_outlined),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                    borderRadius: BorderRadius.circular(18)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Estimated monthly occupied-bed revenue',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 7),
                    Text('PKR ${monthlyEstimate.toString().replaceAllMapped(
                      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    const Text('Estimate only; based on occupied beds × monthly rent per bed.',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ]),
                ),
                const SizedBox(height: 22),
                _Panel(
                  title: 'Overall occupancy',
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('${(occupancy * 100).round()}%',
                        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const Spacer(),
                      Text('$occupiedBeds occupied / $totalBeds beds',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: occupancy, minHeight: 10,
                        color: AppColors.primary, backgroundColor: AppColors.primaryLight)),
                    const SizedBox(height: 8),
                    Text(totalBeds == 0 ? 'Add rooms to start tracking occupancy.'
                      : availableBeds == 0 ? 'All listed beds are currently marked occupied.'
                      : 'You have $availableBeds beds available to students.',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ),
                const SizedBox(height: 14),
                _Panel(
                  title: 'Performance by hostel',
                  child: hostels.isEmpty
                    ? const Text('Add your first hostel and its rooms to see property performance here.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                    : Column(children: hostels.map((hostel) {
                        final capacity = hostel.rooms.fold<int>(0, (sum, r) => sum + r.capacity);
                        final free = hostel.rooms.fold<int>(0, (sum, r) => sum + r.availableBeds);
                        final used = capacity - free;
                        final rate = capacity == 0 ? 0.0 : used / capacity;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(hostel.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                              Text('${(rate * 100).round()}%',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ]),
                            const SizedBox(height: 4),
                            Text('$used occupied • $free available • $capacity total',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            const SizedBox(height: 7),
                            ClipRRect(borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(value: rate, minHeight: 8,
                                color: AppColors.primary, backgroundColor: AppColors.primaryLight)),
                          ]),
                        );
                      }).toList()),
                ),
                const SizedBox(height: 14),
                const _Panel(
                  title: 'Keep your numbers accurate',
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Insight(icon: Icons.bed_outlined, text: 'Update available bed counts whenever a student checks in or checks out.'),
                    SizedBox(height: 12),
                    _Insight(icon: Icons.payments_outlined, text: 'Keep the monthly rent per bed current so revenue estimates remain useful.'),
                    SizedBox(height: 12),
                    _Insight(icon: Icons.location_on_outlined, text: 'A precise Google Maps pin helps students find the right property entrance.'),
                  ]),
                ),
                const SizedBox(height: 20),
                if (snapshot.hasError)
                  const Text('Could not load owner analytics. Pull down to retry.',
                    style: TextStyle(color: AppColors.error, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 15),
      child,
    ]),
  );
}

class _MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _MetricCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: AppColors.primary, size: 21),
      const SizedBox(height: 9),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    ]),
  );
}

class _Insight extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Insight({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: AppColors.primary, size: 18),
    const SizedBox(width: 9),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 11, height: 1.45, color: AppColors.textSecondary))),
  ]);
}
