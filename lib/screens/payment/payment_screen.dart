import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';
import '../../models/booking_record.dart';
import '../../models/booking_storage.dart';

class PaymentScreen extends StatefulWidget {
  final Hostel hostel;
  final String roomType;
  final String studentName;
  final String phoneNumber;
  final String checkInDate;

  const PaymentScreen({
    super.key,
    required this.hostel,
    required this.roomType,
    required this.studentName,
    required this.phoneNumber,
    required this.checkInDate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedMethod;

  final List<Map<String, dynamic>> methods = [
    {
      'name': 'JazzCash',
      'subtitle': 'Pay using JazzCash mobile wallet',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'name': 'EasyPaisa',
      'subtitle': 'Pay using EasyPaisa mobile wallet',
      'icon': Icons.phone_android,
    },
    {
      'name': 'Bank Transfer',
      'subtitle': 'Transfer through your bank',
      'icon': Icons.account_balance_outlined,
    },
    {
      'name': 'Cash',
      'subtitle': 'Pay directly at the hostel',
      'icon': Icons.payments_outlined,
    },
  ];

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  Future<void> confirmPayment() async {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
        ),
      );
      return;
    }

    final booking = BookingRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      hostelName: widget.hostel.name,
      area: widget.hostel.area,
      roomType: widget.roomType,
      monthlyRent: widget.hostel.monthlyRent,
      studentName: widget.studentName,
      phoneNumber: widget.phoneNumber,
      checkInDate: widget.checkInDate,
      paymentMethod: selectedMethod!,
      status: 'Demo Payment',
      createdAt: DateTime.now(),
    );

    try {
      await BookingStorage.saveBooking(booking);

      if (!mounted) return;

      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 55,
          ),
          title: const Text('Booking Saved Successfully'),
          content: Text(
            'Your demo booking for ${widget.hostel.name} '
            'has been saved on this device using $selectedMethod. '
            'No real payment was processed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save booking. Please try again.'),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hostel.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.hostel.area,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Divider(height: 25),
                _summaryRow('Room Type', widget.roomType),
                const SizedBox(height: 12),
                _summaryRow(
                  'Monthly Rent',
                  'PKR ${formatPrice(widget.hostel.monthlyRent)}',
                ),
                const Divider(height: 25),
                _summaryRow(
                  'Total Amount',
                  'PKR ${formatPrice(widget.hostel.monthlyRent)}',
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Choose Payment Method',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...methods.map((method) {
            final name = method['name'] as String;
            final isSelected = selectedMethod == name;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMethod = name;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Demo payment only. No real money will be transferred.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Confirm Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

