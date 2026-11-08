import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';
import '../booking/booking_screen.dart';

class RoomSelectionScreen extends StatefulWidget {
  final Hostel hostel;

  const RoomSelectionScreen({
    super.key,
    required this.hostel,
  });

  @override
  State<RoomSelectionScreen> createState() =>
      _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  String? selectedRoom;

  @override
  Widget build(BuildContext context) {
    final rooms = widget.hostel.roomTypes.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Your Room'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.hostel.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(widget.hostel.area),
          const SizedBox(height: 20),
          const Text(
            'Available Room Types',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: selectedRoom,
            onChanged: (value) {
              setState(() {
                selectedRoom = value;
              });
            },
            child: Column(
              children: rooms.map((room) {
                final rent = widget.hostel.roomPrices?[room] ?? widget.hostel.monthlyRent;
                final availability = widget.hostel.roomAvailability?[room];
                return Card(
                  child: RadioListTile<String>(
                    value: room,
                    enabled: availability == null || availability > 0,
                    title: Text('$room Room'),
                    subtitle: Text(
                      availability == null
                          ? 'PKR $rent / month'
                          : availability == 0
                              ? 'Currently full'
                              : 'PKR $rent / month • $availability beds available',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectedRoom == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          hostel: widget.hostel,
                          roomType: selectedRoom!,
                        ),
                      ),
                    );
                  },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

