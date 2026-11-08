import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/booking_record.dart';
import '../../models/booking_storage.dart';

class BookingTimelineScreen extends StatefulWidget {
  const BookingTimelineScreen({super.key});

  @override
  State<BookingTimelineScreen> createState() => _BookingTimelineScreenState();
}

class _BookingTimelineScreenState extends State<BookingTimelineScreen> {
  late Future<List<BookingRecord>> future;

  @override
  void initState() {
    super.initState();
    future = BookingStorage.getBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Booking Timeline', style: TextStyle(fontWeight: FontWeight.bold))),
      body: FutureBuilder<List<BookingRecord>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load booking history.'),
            );
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(
              child: Text('Your booking timeline will appear here.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) => _timelineCard(bookings[index]),
          );
        },
      ),
    );
  }

  Widget _timelineCard(BookingRecord booking) {
    final status = booking.status.toLowerCase();
    final isComplete = status.contains('confirm') || status.contains('paid') || status.contains('complete');
    final isRejected = status.contains('reject') || status.contains('cancel');
    final steps = ['Booking created', 'Owner review', 'Booking decision', 'Check-in'];
    final activeStep = isRejected ? 2 : isComplete ? 3 : 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(booking.hostelName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 5),
        Text('${booking.roomType} • ${booking.area}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text('Current status: ${booking.status}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isRejected ? AppColors.error : AppColors.primary)),
        const Divider(height: 24),
        ...List.generate(steps.length, (index) {
          final reached = index <= activeStep;
          final last = index == steps.length - 1;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 24, child: Column(children: [
              Icon(reached ? Icons.check_circle : Icons.radio_button_unchecked, size: 19, color: reached ? (isRejected && index == 2 ? AppColors.error : AppColors.success) : AppColors.textMuted),
              if (!last) Container(width: 2, height: 25, color: reached ? AppColors.success.withValues(alpha: 0.45) : AppColors.border),
            ])),
            const SizedBox(width: 10),
            Padding(padding: const EdgeInsets.only(top: 2), child: Text(steps[index], style: TextStyle(fontSize: 12, color: reached ? AppColors.textPrimary : AppColors.textMuted, fontWeight: reached ? FontWeight.w600 : FontWeight.normal))),
          ]);
        }),
        const SizedBox(height: 8),
        Text('Check-in date: ${booking.checkInDate}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text('Demo timeline based on locally saved booking status.', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ]),
    );
  }
}
