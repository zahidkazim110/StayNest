import 'package:flutter/material.dart';

import '../authentication/role_selection_screen.dart';

const Color _navy = Color(0xFF142927);
const Color _blue = Color(0xFF087F75);
const Color _purple = Color(0xFF65A99B);

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _floatController;
  int _currentPage = 0;

  final List<_TutorialData> _pages = const [
    _TutorialData(
      tag: 'DISCOVER YOUR SPACE',
      title: 'Your next home\nstarts here.',
      description:
          'Discover student hostels around your university without wasting hours searching.',
      color: Color(0xFF087F75),
    ),
    _TutorialData(
      tag: 'SMART SEARCH',
      title: 'Your budget.\nYour choice.',
      description:
          'Set your price range, room preference and facilities. Find what matters to you.',
      color: Color(0xFF4D9C8D),
    ),
    _TutorialData(
      tag: 'EXPLORE LOCATIONS',
      title: 'See it before\nyou choose it.',
      description:
          'Explore hostel locations on the map and compare nearby accommodation options.',
      color: Color(0xFF83BFAE),
    ),
    _TutorialData(
      tag: 'YOUR NEW BEGINNING',
      title: 'One step closer\nto feeling home.',
      description:
          'Choose your preferred accommodation and get ready for a better student living experience.',
      color: Color(0xFFD8A64E),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_blue, _purple],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'StayNest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFFB8CCC7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 335,
                                child: _TutorialArtwork(
                                  page: index,
                                  color: data.color,
                                  floatValue: _floatController.value,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: data.color.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: data.color.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    data.tag,
                                    style: TextStyle(
                                      color: data.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 17),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  data.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    height: 1.13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 13),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  data.description,
                                  style: const TextStyle(
                                    color: Color(0xFFB8CCC7),
                                    fontSize: 14,
                                    height: 1.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '0${_currentPage + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentPage + 1) / _pages.length,
                            minHeight: 5,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation(page.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '0${_pages.length}',
                        style: const TextStyle(
                          color: Color(0xFF8BA39C),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (_currentPage > 0)
                        SizedBox(
                          height: 56,
                          width: 58,
                          child: OutlinedButton(
                            onPressed: _back,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            child: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: page.color,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: page.color.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Explore StayNest'
                                      : 'Continue',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MADE FOR STUDENT LIVING',
                    style: TextStyle(
                      color: Color(0xFF667875),
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialData {
  final String tag;
  final String title;
  final String description;
  final Color color;

  const _TutorialData({
    required this.tag,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _TutorialArtwork extends StatelessWidget {
  final int page;
  final Color color;
  final double floatValue;

  const _TutorialArtwork({
    required this.page,
    required this.color,
    required this.floatValue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 255,
          width: 255,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.09),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.13),
                blurRadius: 75,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: Offset(0, (floatValue - 0.5) * 14),
          child: _mainArtwork(),
        ),
        Positioned(
          top: 36,
          right: 2,
          child: _floatingBadge(
            page == 0 ? Icons.verified_rounded :
            page == 1 ? Icons.tune_rounded :
            page == 2 ? Icons.location_on_rounded :
            Icons.check_circle_rounded,
            page == 0 ? 'Find your space' :
            page == 1 ? 'Smart filters' :
            page == 2 ? 'Explore nearby' :
            'Ready to begin',
            color,
          ),
        ),
        Positioned(
          bottom: 28,
          left: 0,
          child: _floatingBadge(
            page == 0 ? Icons.school_rounded :
            page == 1 ? Icons.wallet_rounded :
            page == 2 ? Icons.map_rounded :
            Icons.home_rounded,
            page == 0 ? 'Student living' :
            page == 1 ? 'Your budget' :
            page == 2 ? 'Find locations' :
            'Your new home',
            const Color(0xFF83BFAE),
          ),
        ),
      ],
    );
  }

  Widget _mainArtwork() {
    switch (page) {
      case 0:
        return _phone(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Find your hostel',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2EF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 9),
                    Icon(Icons.search, size: 17, color: _blue),
                    SizedBox(width: 6),
                    Text('Search locations',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Popular hostels',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _miniListing(Icons.apartment_rounded, 'Student Residence', 'Islamabad', '18k'),
              const SizedBox(height: 8),
              _miniListing(Icons.home_work_rounded, 'Campus Living', 'Rawalpindi', '15k'),
            ],
          ),
        );
      case 1:
        return _phone(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your preferences',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 15),
              const Text('Monthly budget',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PKR 8,000', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('PKR 30,000', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EAE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.72,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Room type', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 9),
              const Wrap(
                spacing: 6,
                runSpacing: 7,
                children: [
                  _ChoiceChip('Single', true),
                  _ChoiceChip('Double', false),
                  _ChoiceChip('Shared', false),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Facilities', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF83BFAE), size: 15),
                  SizedBox(width: 6),
                  Text('Wi-Fi', style: TextStyle(fontSize: 11)),
                  SizedBox(width: 15),
                  Icon(Icons.check_circle, color: Color(0xFF83BFAE), size: 15),
                  SizedBox(width: 6),
                  Text('Mess', style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        );
      case 2:
        return _phone(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFE1F3EF),
                  child: CustomPaint(
                    painter: _MapArtworkPainter(),
                    size: Size.infinite,
                  ),
                ),
                const Positioned(
                  top: 37,
                  left: 40,
                  child: _MapPin(color: _blue),
                ),
                const Positioned(
                  top: 105,
                  right: 42,
                  child: _MapPin(color: Color(0xFF83BFAE)),
                ),
                const Positioned(
                  bottom: 48,
                  left: 105,
                  child: _MapPin(color: _purple),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on, color: _blue, size: 19),
                        SizedBox(width: 6),
                        Text('Hostels near you',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return _phone(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF83BFAE).withValues(alpha: 0.13),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 55, color: Color(0xFF83BFAE)),
              ),
              const SizedBox(height: 20),
              const Text('Booking ready!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 8),
              const Text('Your student journey begins here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 20),
              Container(
                height: 38,
                width: 145,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('Explore StayNest',
                      style: TextStyle(color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _phone({required Widget child}) {
    return Container(
      width: 220,
      height: 280,
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white70, width: 4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 35,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _miniListing(IconData icon, String name, String area, String price) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                Text(area, style: const TextStyle(fontSize: 8, color: Colors.grey)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _floatingBadge(IconData icon, String label, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF172B2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 16),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10,
              fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _ChoiceChip(this.label, this.selected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE1F3EF) : const Color(0xFFEDF2EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? _blue : Colors.transparent,
        ),
      ),
      child: Text(label, style: TextStyle(
        color: selected ? _blue : Colors.black54,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      )),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.location_on_rounded, color: color, size: 35);
  }
}

class _MapArtworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final thinRoad = Paint()
      ..color = const Color(0xFFB8DCD2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (i + 1) / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 20), thinRoad);
    }

    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.5,
          size.width, size.height * 0.2);

    final path2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.5,
          size.width * 0.8, size.height);

    canvas.drawPath(path1, road);
    canvas.drawPath(path2, road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
