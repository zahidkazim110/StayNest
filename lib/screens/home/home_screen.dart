import 'package:flutter/material.dart';

import '../../components/cards/hostel_card.dart';
import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../ai_recommendation/ai_recommendation_screen.dart';
import '../discovery/discovery_screen.dart';
import '../hostel_comparison/hostel_comparison_screen.dart';
import '../hostel_details/hostel_details_screen.dart';
import '../notifications/notification_center_screen.dart';
import '../profile/student_profile_screen.dart';
import '../saved_hostels/saved_hostels_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCity = 'Islamabad';
  String selectedRoom = 'All';
  final searchController = TextEditingController();

  final List<Hostel> hostels = const [
    Hostel(
      name: 'University Living Hostel',
      area: 'H-13, Islamabad',
      monthlyRent: 18000,
      distanceKm: 1.2,
      rating: 4.8,
      roomTypes: {'Single', 'Double', 'Shared'},
      facilities: {'Wi-Fi', 'Laundry'},
    ),
    Hostel(
      name: 'Student Comfort Residence',
      area: 'G-10, Islamabad',
      monthlyRent: 15000,
      distanceKm: 2.5,
      rating: 4.6,
      roomTypes: {'Double', 'Shared'},
      facilities: {'Wi-Fi', 'Mess'},
    ),
    Hostel(
      name: 'Campus View Hostel',
      area: 'Satellite Town, Rawalpindi',
      monthlyRent: 12000,
      distanceKm: 3.0,
      rating: 4.7,
      roomTypes: {'Single', 'Shared'},
      facilities: {'Wi-Fi', 'AC'},
    ),
  ];

  List<Hostel> get filteredHostels {
    return hostels.where((hostel) {
      final cityMatch = hostel.area.toLowerCase().contains(
        selectedCity.toLowerCase(),
      );
      final roomMatch =
          selectedRoom == 'All' || hostel.roomTypes.contains(selectedRoom);
      final query = searchController.text.trim().toLowerCase();
      final searchMatch =
          query.isEmpty ||
          hostel.name.toLowerCase().contains(query) ||
          hostel.area.toLowerCase().contains(query);
      return cityMatch && roomMatch && searchMatch;
    }).toList();
  }

  void openDiscovery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
    );
  }

  void openSavedHostels() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedHostelsScreen()),
    );
  }

  void openAiRecommendations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AIRecommendationScreen(hostels: hostels),
      ),
    );
  }

  void openAiAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AIAssistantScreen(hostels: hostels)),
    );
  }

  void openComparison() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HostelComparisonScreen(hostels: hostels),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredHostels;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _header(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: _hero(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _searchBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 27, 20, 0),
                child: _citySection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                child: _roomSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 27, 20, 0),
                child: _toolsSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 15),
                child: _sectionHeading(
                  'Recommended for you',
                  subtitle: 'Explore places that could feel like home.',
                  trailing: 'Explore all',
                  onTrailingTap: openDiscovery,
                ),
              ),
            ),
            if (results.isEmpty)
              SliverToBoxAdapter(child: _emptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final hostel = results[index];
                    return HostelCard(
                      name: hostel.name,
                      location: hostel.area,
                      price: 'PKR ${_formatPrice(hostel.monthlyRent)} / mo',
                      rating: hostel.rating,
                      imageUrl: '',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HostelDetailsScreen(hostel: hostel),
                          ),
                        );
                      },
                    );
                  }, childCount: results.length),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: _bottomDiscoveryCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.20),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_work_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'StayNest',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Your student living partner',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _headerAction(
          icon: Icons.notifications_none_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotificationCenterScreen(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _headerAction(
          icon: Icons.person_outline_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentProfileScreen()),
          ),
        ),
      ],
    );
  }

  Widget _headerAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 21),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(21, 22, 19, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF315BE8), Color(0xFF2449C8), Color(0xFF172B62)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -37,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 24,
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: -24,
            child: Icon(
              Icons.apartment_rounded,
              size: 118,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Text(
                  'STUDENT LIVING, SIMPLIFIED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Find a place\nto call home.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.12,
                  letterSpacing: -0.6,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Discover student hostels around your campus.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: openDiscovery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    minimumSize: const Size(145, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore hostels',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 7),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 4, 7, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08172B4D),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.primary, size: 23),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search by hostel or location',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          Material(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: openDiscovery,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                height: 42,
                width: 42,
                child: Icon(Icons.tune_rounded, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _citySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('Choose your city'),
        const SizedBox(height: 13),
        Row(
          children: [
            _cityChip('Islamabad'),
            const SizedBox(width: 10),
            _cityChip('Rawalpindi'),
          ],
        ),
      ],
    );
  }

  Widget _cityChip(String city) {
    final selected = selectedCity == city;
    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => setState(() => selectedCity = city),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  city,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roomSection() {
    const categories = [
      ('All', Icons.grid_view_rounded),
      ('Single', Icons.person_outline_rounded),
      ('Double', Icons.people_outline_rounded),
      ('Shared', Icons.groups_2_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('What room suits you?'),
        const SizedBox(height: 13),
        Row(
          children: categories.map((category) {
            final selected = selectedRoom == category.$1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 7),
                child: Material(
                  color: selected ? AppColors.primaryLight : AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: () => setState(() => selectedRoom = category.$1),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(category.$2, color: AppColors.primary, size: 21),
                          const SizedBox(height: 7),
                          Text(
                            category.$1,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _toolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          'Make your search easier',
          subtitle: 'Helpful tools for finding the right stay.',
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: _toolCard(
                icon: Icons.auto_awesome_rounded,
                title: 'AI picks',
                subtitle: 'Personalised matches',
                onTap: openAiRecommendations,
                accent: const Color(0xFF7357D8),
                tint: const Color(0xFFF1EDFF),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _toolCard(
                icon: Icons.favorite_rounded,
                title: 'Saved',
                subtitle: 'Your shortlist',
                onTap: openSavedHostels,
                accent: const Color(0xFFE05C78),
                tint: const Color(0xFFFFEEF2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _toolCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'AI assistant',
                subtitle: 'Ask a question',
                onTap: openAiAssistant,
                accent: const Color(0xFF168B83),
                tint: const Color(0xFFE8F7F5),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _toolCard(
                icon: Icons.compare_arrows_rounded,
                title: 'Compare',
                subtitle: 'Check your options',
                onTap: openComparison,
                accent: AppColors.primary,
                tint: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _toolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color accent,
    required Color tint,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(
    String title, {
    String? subtitle,
    String? trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null)
          TextButton(
            onPressed: onTrailingTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppColors.textMuted,
              size: 38,
            ),
            SizedBox(height: 10),
            Text(
              'No hostels found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Try another city, room type or search term.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomDiscoveryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still exploring?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'See more available hostel options.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: openDiscovery,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => (match[1] ?? '') + ',',
    );
  }
}
