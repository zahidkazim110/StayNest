import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color mapBlue = Color(0xFF315BE8);
const Color mapNavy = Color(0xFF101B36);

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
  Set<String> selectedFacilities = {};

  final List<Map<String, String>> hostels = [
    {
      'name': 'University Living Hostel',
      'area': 'H-13, Islamabad',
      'price': 'PKR 18,000 / month',
      'distance': '0.8 km away',
      'rating': '4.8',
    },
    {
      'name': 'Student Comfort Residence',
      'area': 'G-10, Islamabad',
      'price': 'PKR 15,000 / month',
      'distance': '1.4 km away',
      'rating': '4.6',
    },
    {
      'name': 'Campus View Hostel',
      'area': 'Satellite Town, Rawalpindi',
      'price': 'PKR 12,000 / month',
      'distance': '2.1 km away',
      'rating': '4.7',
    },
  ];

  @override
  void initState() {
    super.initState();

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
    )..forward();

    cards = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

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
                color: Color(0xFFF8FAFF),
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
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
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
                            selectedColor: const Color(0xFFDCE5FF),
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
                        return CheckboxListTile(
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
                            setState(() {});
                            Navigator.pop(sheetContext);
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

  // HEADER
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

  // ANIMATED MAP
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
            Positioned.fill(
              child: CustomPaint(
                painter: MapPainter(
                  radarValue: radar.value,
                  particleValue: particles.value,
                ),
              ),
            ),

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

            Positioned(
              left: width * .5 - 85,
              top: height * .48 - 85,
              child: RadarAnimation(value: radar.value),
            ),

            ...List.generate(markerPositions.length, (index) {
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
            }),

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
                      color: Color(0xFFFFC45B),
                      size: 43,
                      shadows: [Shadow(color: Colors.orange, blurRadius: 22)],
                    ),
                  );
                },
              ),
            ),

            Positioned(
              left: 15,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xDD172746),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radar_rounded,
                      color: Color(0xFF6CA8FF),
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

  // AREA SELECTOR
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
          color: active ? mapBlue : const Color(0xCC172746),
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

  // BOTTOM HOSTEL PANEL
  Widget _bottomPanel() {
    final hostel = hostels[selectedHostel];

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
                color: Color(0xFFF8FAFF),
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
                        '${hostels.length} results',
                        style: const TextStyle(
                          color: mapBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE9EDFA)),
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
                            color: const Color(0xFFE8EEFF),
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

                  Row(
                    children: List.generate(hostels.length, (index) {
                      final active = selectedHostel == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => selectMarker(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 7),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: active ? mapBlue : const Color(0xFFEAF0FF),
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

// RADAR ANIMATION
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

// RADAR PAINTER
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

// HOSTEL MARKER
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
          color: active ? const Color(0xFFFFC45B) : mapBlue,
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

// MAP PAINTER
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
          colors: [Color(0xFF14294A), Color(0xFF0A142B), Color(0xFF192E50)],
        ).createShader(rect),
    );

    // MAP GRID
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: .045)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 35) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += 35) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ROADS
    final roadPaint = Paint()
      ..color = const Color(0xFF5274A5).withValues(alpha: .4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final roadGlow = Paint()
      ..color = const Color(0xFF438EFF).withValues(alpha: .15)
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

    // MOVING CITY PARTICLES
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

    // CITY LABELS
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
