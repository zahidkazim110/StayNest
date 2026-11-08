import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';
import '../../components/buttons/favorite_button.dart';
import '../room_selection/room_selection_screen.dart';
import '../hostel_reviews/hostel_reviews_screen.dart';

class HostelDetailsScreen extends StatelessWidget {
  final Hostel hostel;

  const HostelDetailsScreen({super.key, required this.hostel});

  String get formattedRent {
    final value = hostel.monthlyRent.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return 'PKR $value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: const Text(
              'Hostel Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [FavoriteButton(hostel: hostel)],
            flexibleSpace: FlexibleSpaceBar(background: _heroImage()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _titleSection(),
                const SizedBox(height: 24),
                _priceSection(),
                const SizedBox(height: 25),
                _sectionHeading('About this hostel'),
                const SizedBox(height: 10),
                Text(
                  hostel.description?.trim().isNotEmpty == true\n                      ? hostel.description!\n                      : '${hostel.name} is a student accommodation option located in ${hostel.area}. Explore the available room types and facilities before making your booking.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 25),
                _sectionHeading('Room Types'),
                const SizedBox(height: 13),
                _roomTypes(),
                const SizedBox(height: 25),
                _sectionHeading('Facilities & Amenities'),
                const SizedBox(height: 13),
                _facilities(),
                const SizedBox(height: 25),
                _sectionHeading('Reviews & Ratings'),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HostelReviewsScreen(hostel: hostel),
                    ),
                  ),
                  icon: const Icon(Icons.star_outline_rounded),
                  label: const Text('Read or Write Reviews'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _sectionHeading('Location'),
                const SizedBox(height: 12),
                _locationCard(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bookingBar(context),
    );
  }

  Widget _heroImage() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF087F75), Color(0xFF172B2A)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -30,
            top: 20,
            child: Icon(
              Icons.location_city_rounded,
              size: 230,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.apartment_rounded,
                size: 85,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                hostel.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Student Accommodation',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          Positioned(
            bottom: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                    size: 17,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Property preview',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hostel.name,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 19,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                hostel.area,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _infoChip(
              Icons.star_rounded,
              hostel.rating.toStringAsFixed(1),
              AppColors.gold,
            ),
            const SizedBox(width: 10),
            _infoChip(
              Icons.near_me_outlined,
              '${hostel.distanceKm.toStringAsFixed(1)} km away',
              AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _priceSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Rent',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Accommodation price',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formattedRent,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _roomTypes() {
    if (hostel.roomTypes.isEmpty) {
      return const Text('Room information is not available.');
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: hostel.roomTypes.map((room) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bed_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                room,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _facilities() {
    if (hostel.facilities.isEmpty) {
      return const Text('Facility information is not available.');
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: hostel.facilities.map((facility) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                facility,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _locationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hostel Address',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hostel.area,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (hostel.contactPhone?.isNotEmpty == true) ...[
                  const SizedBox(height: 7),
                  Text(
                    'Owner contact: \${hostel.contactPhone}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
                if (hostel.availableBeds != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    '\${hostel.availableBeds} beds currently available',
                    style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
                if (hostel.googleMapsUrl?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: hostel.googleMapsUrl!));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google Maps link copied. Paste it into Google Maps to navigate.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.map_outlined, size: 17),
                    label: const Text('Copy Google Maps location'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 17),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 13, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 53,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomSelectionScreen(hostel: hostel),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Book Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(width: 9),
                Icon(Icons.arrow_forward_rounded, size: 19),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
