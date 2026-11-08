import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class OwnerAnalyticsScreen extends StatelessWidget {
  const OwnerAnalyticsScreen({super.key});

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const _values = [0.42, 0.58, 0.51, 0.76, 0.68, 0.92];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Hostel Analytics', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Performance overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Illustrative demo figures. Connect owner records to show live analytics.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 18),
          const Row(children: [
            Expanded(child: _MetricCard(title: 'Occupancy', value: '67%', icon: Icons.bed_rounded)),
            SizedBox(width: 10),
            Expanded(child: _MetricCard(title: 'Monthly revenue', value: 'PKR 240K', icon: Icons.payments_rounded)),
          ]),
          const SizedBox(height: 10),
          const Row(children: [
            Expanded(child: _MetricCard(title: 'Bookings', value: '18', icon: Icons.event_available_rounded)),
            SizedBox(width: 10),
            Expanded(child: _MetricCard(title: 'Pending', value: '5', icon: Icons.pending_actions_rounded)),
          ]),
          const SizedBox(height: 24),
          _panel(
            title: 'Revenue trend',
            child: SizedBox(
              height: 190,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_months.length, (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('${(_values[index] * 100).round()}%', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Container(height: 125 * _values[index], decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(7))),
                      const SizedBox(height: 7),
                      Text(_months[index], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ]),
                  ),
                )),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _panel(
            title: 'Room occupancy',
            child: Column(children: [
              _progressRow('Occupied rooms', 16, 24, AppColors.primary),
              const SizedBox(height: 15),
              _progressRow('Available rooms', 8, 24, AppColors.success),
            ]),
          ),
          const SizedBox(height: 14),
          _panel(
            title: 'Owner insights',
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Insight(icon: Icons.trending_up_rounded, text: 'Occupancy is shown as a sample KPI for the demo dashboard.'),
              SizedBox(height: 12),
              _Insight(icon: Icons.notifications_active_outlined, text: 'Review pending booking requests regularly.'),
              SizedBox(height: 12),
              _Insight(icon: Icons.price_check_rounded, text: 'Compare monthly rent and occupancy before adjusting pricing.'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 18),
      child,
    ]),
  );

  Widget _progressRow(String label, int value, int total, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))), Text('$value / $total', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))]),
    const SizedBox(height: 8),
    ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: value / total, minHeight: 9, color: color, backgroundColor: AppColors.surfaceSecondary)),
  ]);
}

class _MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _MetricCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppColors.primary),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );
}

class _Insight extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Insight({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: AppColors.primary, size: 19),
    const SizedBox(width: 10),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary))),
  ]);
}
