import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/hostel.dart';
import '../../models/hostel_activity_storage.dart';
import '../../models/owner_hostel.dart';
import '../hostel_details/hostel_details_screen.dart';

const Color mapBlue = Color(0xFF087F75);
const Color mapNavy = Color(0xFF142927);

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with TickerProviderStateMixin {
  late AnimationController radar;
  late AnimationController particles;
  late AnimationController zoom;
  late AnimationController cards;

  String selectedArea = 'Islamabad';
  int selectedHostel = 0;
  RangeValues budgetRange = const RangeValues(8000, 30000);
  String selectedRoomType = 'Any';
  String sortBy = 'Recommended';
  String searchQuery = '';
  Set<String> selectedFacilities = {};

  final List<Hostel> hostels = [
    const Hostel(
      name: 'University Living Hostel',
      area: 'H-13, Islamabad',
      monthlyRent: 18000,
      distanceKm: 0.8,
      rating: 4.8,
      roomTypes: {'Single', 'Double', 'Shared'},
      facilities: {'Wi-Fi', 'Laundry'},
    ),
    const Hostel(
      name: 'Student Comfort Residence',
      area: 'G-10, Islamabad',
      monthlyRent: 15000,
      distanceKm: 1.4,
      rating: 4.6,
      roomTypes: {'Double', 'Shared'},
      facilities: {'Wi-Fi', 'Mess'},
    ),
    const Hostel(
      name: 'Campus View Hostel',
      area: 'Satellite Town, Rawalpindi',
      monthlyRent: 12000,
      distanceKm: 2.1,
      rating: 4.7,
      roomTypes: {'Single', 'Shared'},
      facilities: {'Wi-Fi', 'Air Conditioning'},
    ),
  ];

  Future<void> _loadOwnerListings() async {
    final listings = await OwnerHostelStorage.getHostels();
    if (!mounted) return;
    final converted = <Hostel>[];
    for (final listing in listings) {
      if (listing.rooms.isEmpty) continue;
      final rent = listing.rooms.map((room) => room.monthlyRent)
          .reduce((a, b) => a < b ? a : b);
      final roomTypes = listing.rooms.map((room) => room.roomType).toSet();
      final roomPrices = <String, int>{};
      final roomAvailability = <String, int>{};
      for (final room in listing.rooms) {
        final oldPrice = roomPrices[room.roomType];
        if (oldPrice == null || room.monthlyRent < oldPrice) roomPrices[room.roomType] = room.monthlyRent;
        roomAvailability.update(room.roomType, (value) => value + room.availableBeds, ifAbsent: () => room.availableBeds);
      }
      final availableBeds = listing.rooms.fold<int>(0, (sum, room) => sum + room.availableBeds);
      final facilities = <String>{};
      for (final facility in listing.facilities) {
        final value = facility.toLowerCase();
        if (value.contains('wi-fi')) {
          facilities.add('Wi-Fi');
        } else if (value.contains('air')) {
          facilities.add('Air Conditioning');
        } else if (value.contains('laundry')) {
          facilities.add('Laundry');
        } else if (value.contains('mess')) {
          facilities.add('Mess');
        } else {
          facilities.add(facility);
        }
      }
      for (final room in listing.rooms) {
        for (final facility in room.facilities) {
          if (facility.toLowerCase() == 'wi-fi') facilities.add('Wi-Fi');
          if (facility.toLowerCase() == 'ac') facilities.add('Air Conditioning');
        }
      }
      converted.add(Hostel(
        name: listing.name,
        area: '${listing.address}, ${listing.city}',
        monthlyRent: rent,
        distanceKm: 0,
        rating: 0,
        roomTypes: roomTypes,
        facilities: facilities,
        googleMapsUrl: listing.googleMapsUrl,
        contactPhone: listing.contactPhone,
        description: listing.description,
        availableBeds: availableBeds,
        isOwnerListing: true,
        roomPrices: roomPrices,
        roomAvailability: roomAvailability,
      ));
    }
    setState(() {
      hostels.removeWhere((hostel) => hostel.isOwnerListing);
      hostels.addAll(converted);
    });
  }

  List<Hostel> get filteredHostels {
    final results = hostels.where((hostel) {
      final matchesArea = hostel.area.toLowerCase().contains(selectedArea.toLowerCase());
      final matchesBudget =
          hostel.monthlyRent >= budgetRange.start &&
          hostel.monthlyRent <= budgetRange.end;
      final matchesRoomType =
          selectedRoomType == 'Any' ||
          hostel.roomTypes.contains(selectedRoomType);
      final matchesFacilities = selectedFacilities.isEmpty ||
          selectedFacilities.every((facility) => hostel.facilities.contains(facility));
      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          hostel.name.toLowerCase().contains(query) ||
          hostel.area.toLowerCase().contains(query) ||
          hostel.facilities.any((facility) => facility.toLowerCase().contains(query));
      return matchesArea && matchesBudget && matchesRoomType &&
          matchesFacilities && matchesSearch;
    }).toList();

    if (sortBy == 'Lowest price') {
      results.sort((a, b) => a.monthlyRent.compareTo(b.monthlyRent));
    } else if (sortBy == 'Highest rating') {
      results.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortBy == 'Nearest') {
      results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return results;
  }

  @override
  void initState() {
    super.initState();
    _loadOwnerListings();

    radar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    particles = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    zoom = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    cards = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    zoom.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) cards.forward();
    });
  }

  @override
  void dispose() {
    radar.dispose();
    particles.dispose();
    zoom.dispose();
    cards.dispose();
    super.dispose();
  }

  void selectMarker(int index) {
    setState(() {
      selectedHostel = index;
    });
    cards.forward(from: 0);
  }

  // FILTER BOTTOM SHEET
  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                22,
                12,
                22,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          height: 5,
                          width: 42,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter Hostels',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: mapNavy,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                budgetRange = const RangeValues(8000, 30000);
                                selectedRoomType = 'Any';
                                selectedFacilities.clear();
                                searchQuery = '';
                                sortBy = 'Recommended';
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) => setModalState(() => searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search hostel, area or facility',
                          prefixIcon: const Icon(Icons.search_rounded, color: mapBlue),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(color: Color(0xFFE3EAE5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Sort results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mapNavy)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: sortBy,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
                        ),
                        items: ['Recommended', 'Lowest price', 'Highest rating', 'Nearest']
                            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => sortBy = value);
                          }
                        },
                      ),
                      const SizedBox(height: 22),

                      const Text(
                        'Monthly Budget',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: mapNavy,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'PKR ${budgetRange.start.round()} - '
                        'PKR ${budgetRange.end.round()}',
                        style: const TextStyle(
                          color: mapBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      RangeSlider(
                        values: budgetRange,
                        min: 5000,
                        max: 50000,
                        divisions: 45,
                        activeColor: mapBlue,
                        onChanged: (value) {
                          setModalState(() {
                            budgetRange = value;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Room Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: mapNavy,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        children: ['Any', 'Single', 'Double', 'Shared'].map((
                          type,
                        ) {
                          return ChoiceChip(
                            label: Text(type),
                            selected: selectedRoomType == type,
                            selectedColor: const Color(0xFFDCEFE9),
                            onSelected: (_) {
                              setModalState(() {
                                selectedRoomType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Facilities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: mapNavy,
                        ),
                      ),

                      ...['Wi-Fi', 'Air Conditioning', 'Laundry', 'Mess'].map((
                        facility,
                      ) {
                        return Material(
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: mapBlue,
                            title: Text(facility),
                            value: selectedFacilities.contains(facility),
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  selectedFacilities.add(facility);
                                } else {
                                  selectedFacilities.remove(facility);
                                }
                              });
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mapBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedHostel = 0;
                            });
                            Navigator.pop(sheetContext);
                            cards.forward(from: 0);
                          },
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mapNavy,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([radar, particles, zoom]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.94 + zoom.value * 0.06,
                    child: _map(),
                  );
                },
              ),
            ),
            _bottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 15),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: mapBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StayNest Discovery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Explore student accommodation',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showFilters,
            tooltip: 'Filter hostels',
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _map() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final markerPositions = [
          Offset(width * .28, height * .28),
          Offset(width * .70, height * .43),
          Offset(width * .43, height * .72),
        ];

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Map background
            Positioned.fill(
              child: CustomPaint(
                painter: MapPainter(
                  radarValue: radar.value,
                  particleValue: particles.value,
                ),
              ),
            ),

            // Area selector
            Positioned(
              top: 15,
              left: 15,
              right: 15,
              child: Row(
                children: [
                  _areaButton('Islamabad'),
                  const SizedBox(width: 8),
                  _areaButton('Rawalpindi'),
                ],
              ),
            ),

            // Radar scanning circle
            Positioned(
              left: width * .5 - 85,
              top: height * .48 - 85,
              child: RadarAnimation(value: radar.value),
            ),

            // Hostel markers
            ...List.generate(
              math.min(markerPositions.length, filteredHostels.length),
              (index) {
                final position = markerPositions[index];

                return Positioned(
                  left: position.dx - 22,
                  top: position.dy - 30,
                  child: GestureDetector(
                    onTap: () => selectMarker(index),
                    child: HostelMarker(
                      active: selectedHostel == index,
                      value: radar.value,
                    ),
                  ),
                );
              },
            ),

            // Central location pin
            Positioned(
              left: width * .5 - 20,
              top: height * .48 - 24,
              child: AnimatedBuilder(
                animation: particles,
                builder: (context, child) {
                  final bounce = math.sin(particles.value * math.pi * 2) * 5;

                  return Transform.translate(
                    offset: Offset(0, bounce),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFD8A64E),
                      size: 43,
                      shadows: [Shadow(color: Colors.orange, blurRadius: 22)],
                    ),
                  );
                },
              ),
            ),

            // Scanning label
            Positioned(
              left: 15,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xDD172B2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radar_rounded,
                      color: Color(0xFF65A99B),
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'SCANNING $selectedArea',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _areaButton(String area) {
    final active = selectedArea == area;

    return GestureDetector(
      onTap: () {
        setState(() => selectedArea = area);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? mapBlue : const Color(0xCC172B2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.white30 : Colors.white12),
        ),
        child: Text(
          area,
          style: TextStyle(
            color: Colors.white,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _bottomPanel() {
    final results = filteredHostels;

    if (results.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF6F7F3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
        ),
        child: const Text(
          'No hostels match your budget. Try increasing your budget range.',
          textAlign: TextAlign.center,
          style: TextStyle(color: mapNavy, fontWeight: FontWeight.w600),
        ),
      );
    }

    final safeIndex = selectedHostel < results.length ? selectedHostel : 0;
    final hostel = results[safeIndex];

    return AnimatedBuilder(
      animation: cards,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 55 * (1 - cards.value)),
          child: Opacity(
            opacity: cards.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nearby hostels',
                          style: TextStyle(
                            color: mapNavy,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${results.length} results',
                        style: const TextStyle(
                          color: mapBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Hostel preview
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEDF2EF)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .04),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F3EF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.apartment_rounded,
                            size: 38,
                            color: mapBlue,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hostel['name']!,
                                style: const TextStyle(
                                  color: mapNavy,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                hostel['area']!,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                hostel['price']!,
                                style: const TextStyle(
                                  color: mapBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.orange,
                              size: 19,
                            ),
                            Text(
                              hostel['rating']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: mapNavy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await HostelActivityStorage.addRecentlyViewed(hostel);
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HostelDetailsScreen(hostel: hostel),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('View Hostel Details'),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Marker selection
                  Row(
                    children: List.generate(results.length, (index) {
                      final active = selectedHostel == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => selectMarker(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 7),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: active ? mapBlue : const Color(0xFFE1F3EF),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text(
                                'Hostel ${index + 1}',
                                style: TextStyle(
                                  color: active ? Colors.white : mapBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RadarAnimation extends StatelessWidget {
  final double value;

  const RadarAnimation({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      width: 170,
      child: CustomPaint(painter: RadarPainter(value)),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double value;

  RadarPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      final progress = (value + i / 3) % 1;
      final radius = 20 + progress * 65;

      final paint = Paint()
        ..color = Colors.blueAccent.withValues(alpha: (1 - progress) * .3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) => true;
}

class HostelMarker extends StatelessWidget {
  final bool active;
  final double value;

  const HostelMarker({super.key, required this.active, required this.value});

  @override
  Widget build(BuildContext context) {
    final scale = active ? 1.1 + value * .08 : 1.0;

    return Transform.scale(
      scale: scale,
      child: Container(
        height: 43,
        width: 43,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD8A64E) : mapBlue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: (active ? Colors.orange : Colors.blue).withValues(
                alpha: .5,
              ),
              blurRadius: active ? 22 : 12,
              spreadRadius: active ? 3 : 0,
            ),
          ],
        ),
        child: Icon(
          Icons.home_rounded,
          color: active ? mapNavy : Colors.white,
          size: 21,
        ),
      ),
    );
  }
}

// Draws the animated map, roads and city lights.
class MapPainter extends CustomPainter {
  final double radarValue;
  final double particleValue;

  MapPainter({required this.radarValue, required this.particleValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF193B38), Color(0xFF102321), Color(0xFF21433F)],
        ).createShader(rect),
    );

    // Subtle map grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: .045)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 35) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += 35) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Roads
    final roadPaint = Paint()
      ..color = const Color(0xFF668A83).withValues(alpha: .4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final roadGlow = Paint()
      ..color = const Color(0xFF087F75).withValues(alpha: .15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final roads = [
      [
        Offset(0, size.height * .25),
        Offset(size.width * .3, size.height * .32),
        Offset(size.width * .55, size.height * .20),
        Offset(size.width, size.height * .37),
      ],
      [
        Offset(size.width * .12, size.height),
        Offset(size.width * .38, size.height * .63),
        Offset(size.width * .67, size.height * .52),
        Offset(size.width, size.height * .72),
      ],
      [
        Offset(0, size.height * .75),
        Offset(size.width * .35, size.height * .47),
        Offset(size.width * .70, size.height * .32),
        Offset(size.width, size.height * .12),
      ],
    ];

    for (final road in roads) {
      final path = Path()..moveTo(road[0].dx, road[0].dy);

      for (int i = 1; i < road.length; i++) {
        path.lineTo(road[i].dx, road[i].dy);
      }

      canvas.drawPath(path, roadGlow);
      canvas.drawPath(path, roadPaint);
    }

    // Moving light particles
    final random = math.Random(17);

    for (int i = 0; i < 45; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final blink = .3 + .7 * math.sin((particleValue * math.pi * 2) + i).abs();

      canvas.drawCircle(
        Offset(x, y),
        1.2,
        Paint()..color = Colors.lightBlueAccent.withValues(alpha: blink * .65),
      );
    }

    // City location labels
    _drawLabel(canvas, 'ISLAMABAD', Offset(15, size.height * .16));
    _drawLabel(
      canvas,
      'F-10 SECTOR',
      Offset(size.width * .55, size.height * .30),
    );
    _drawLabel(
      canvas,
      'G-11 SECTOR',
      Offset(size.width * .10, size.height * .61),
    );
    _drawLabel(
      canvas,
      'RAWALPINDI',
      Offset(size.width * .55, size.height * .83),
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .5),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}
