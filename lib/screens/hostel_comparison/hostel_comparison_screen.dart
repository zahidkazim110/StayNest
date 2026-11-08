import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';
import '../hostel_details/hostel_details_screen.dart';

class HostelComparisonScreen extends StatefulWidget {
  final List<Hostel> hostels;
  const HostelComparisonScreen({super.key, required this.hostels});

  @override
  State<HostelComparisonScreen> createState() => _HostelComparisonScreenState();
}

class _HostelComparisonScreenState extends State<HostelComparisonScreen> {
  final Set<Hostel> selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Compare Hostels', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Select up to three hostels to compare their key details.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ...widget.hostels.map((hostel) {
            final active = selected.contains(hostel);
            return Card(
              color: AppColors.surface,
              child: CheckboxListTile(
                value: active,
                activeColor: AppColors.primary,
                title: Text(hostel.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${hostel.area} • PKR ${hostel.monthlyRent}/month'),
                onChanged: (value) {
                  setState(() {
                    if (value == true && selected.length < 3) {
                      selected.add(hostel);
                    } else if (value == false) {
                      selected.remove(hostel);
                    }
                  });
                  if (value == true && selected.length > 3) {
                    selected.remove(hostel);
                  }
                },
              ),
            );
          }),
          const SizedBox(height: 12),
          if (selected.length >= 2) _comparisonTable(),
          const SizedBox(height: 16),
          if (selected.length == 1)
            const Text('Select at least one more hostel to see a comparison.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _comparisonTable() {
    final items = selected.toList();
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          _row('Monthly rent', items.map((e) => 'PKR ${e.monthlyRent}').toList()),
          _row('Location', items.map((e) => e.area).toList()),
          _row('Distance', items.map((e) => '${e.distanceKm.toStringAsFixed(1)} km').toList()),
          _row('Rating', items.map((e) => '★ ${e.rating.toStringAsFixed(1)}').toList()),
          _row('Room types', items.map((e) => e.roomTypes.join(', ')).toList()),
          _row('Facilities', items.map((e) => e.facilities.join(', ')).toList()),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((hostel) => OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HostelDetailsScreen(hostel: hostel))),
                child: Text('View ${hostel.name.split(' ').first}'),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, List<String> values) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          Row(children: values.map((value) => Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary), maxLines: 3, overflow: TextOverflow.ellipsis),
          ))).toList()),
        ],
      ),
    );
  }
}
