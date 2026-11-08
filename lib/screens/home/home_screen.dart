import '../profile/student_profile_screen.dart';
import '../notifications/notification_center_screen.dart';

import 'package:flutter/material.dart';

import '../../components/cards/hostel_card.dart';
import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';
import '../saved_hostels/saved_hostels_screen.dart';
import '../ai_recommendation/ai_recommendation_screen.dart';
import '../hostel_details/hostel_details_screen.dart';
import '../discovery/discovery_screen.dart';

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
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 30),
                    const Text(
                      'Find Your Perfect',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Student Hostel',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Discover comfortable and affordable student accommodation.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _searchBar(),
                    const SizedBox(height: 25),
                    _sectionTitle('Choose Your City'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _cityButton('Islamabad'),
                        const SizedBox(width: 10),
                        _cityButton('Rawalpindi'),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _sectionTitle('Explore Room Types'),
                    const SizedBox(height: 12),
                    _roomCategories(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavedHostelsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.favorite_rounded),
                        label: const Text('My Favorites & Recently Viewed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AIRecommendationScreen(hostels: hostels),
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('AI Hostel Recommendations'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _sectionTitle('Recommended Hostels'),
                    const SizedBox(height: 5),
                    const Text(
                      'Find a place that feels like home.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            if (results.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text(
                      'No hostels found. Try another search or filter.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final hostel = results[index];

                    return HostelCard(
                      name: hostel.name,
                      location: hostel.area,
                      price: 'PKR ${hostel.monthlyRent} / month',
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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: openDiscovery,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Explore All Hostels'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
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
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.home_work_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 11),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'StayNest',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Find your student home',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationCenterScreen(),
              ),
            );
          },
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentProfileScreen()),
            );
          },
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search hostel or location...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: openDiscovery,
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _cityButton(String city) {
    final selected = selectedCity == city;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCity = city),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: selected ? Colors.white : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                city,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roomCategories() {
    final categories = [
      {'name': 'All', 'icon': Icons.grid_view_rounded},
      {'name': 'Single', 'icon': Icons.person_outline},
      {'name': 'Double', 'icon': Icons.people_outline},
      {'name': 'Shared', 'icon': Icons.groups_outlined},
    ];

    return Row(
      children: categories.map((category) {
        final name = category['name'] as String;
        final icon = category['icon'] as IconData;
        final selected = selectedRoom == name;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedRoom = name),
            child: Container(
              margin: const EdgeInsets.only(right: 7),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, color: AppColors.primary, size: 23),
                  const SizedBox(height: 7),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
