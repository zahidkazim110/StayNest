import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../components/buttons/primary_button.dart';
import '../../core/theme/app_colors.dart';
import '../tutorial/tutorial_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController entrance;
  late AnimationController floating;
  late AnimationController pulse;
  late AnimationController door;

  bool opening = false;

  @override
  void initState() {
    super.initState();

    entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    floating = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    door = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
  }

  @override
  void dispose() {
    entrance.dispose();
    floating.dispose();
    pulse.dispose();
    door.dispose();
    super.dispose();
  }

  Future<void> openDoor() async {
    if (opening) return;

    setState(() {
      opening = true;
    });

    await door.forward();

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1100),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const TutorialScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.12, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget buildWindow() {
    return Container(
      height: 30,
      width: 25,
      decoration: BoxDecoration(
        color: const Color(0xFFDCE7FF),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFB8CCFF), width: 1.5),
      ),
      child: const Icon(
        Icons.window_rounded,
        size: 17,
        color: AppColors.primary,
      ),
    );
  }

  Widget floatingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 33,
            width: 33,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 8,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget hostelIllustration(double floatValue) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background glow
          Container(
            height: 225,
            width: 225,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 45,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),

          // Hostel building
          Transform.translate(
            offset: Offset(0, -floatValue * 0.3),
            child: Container(
              height: 205,
              width: 165,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDCE5FF), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'STUDENT RESIDENCE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [buildWindow(), buildWindow(), buildWindow()],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [buildWindow(), buildWindow(), buildWindow()],
                  ),

                  const Spacer(),

                  // Door animation
                  SizedBox(
                    height: 55,
                    width: 57,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Warm light inside the entrance
                        AnimatedBuilder(
                          animation: door,
                          builder: (context, child) {
                            return Container(
                              height: 49,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(
                                  alpha: 0.15 + door.value * 0.65,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(
                                      alpha: door.value * 0.65,
                                    ),
                                    blurRadius: 25 * door.value,
                                    spreadRadius: 5 * door.value,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Door frame
                        Container(
                          height: 48,
                          width: 39,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C6B43),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(7),
                            ),
                            border: Border.all(
                              color: const Color(0xFF704323),
                              width: 2,
                            ),
                          ),
                        ),

                        // Rotating door
                        AnimatedBuilder(
                          animation: door,
                          builder: (context, child) {
                            return Transform(
                              alignment: Alignment.centerLeft,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.002)
                                ..rotateY(-door.value * 1.35),
                              child: Container(
                                height: 45,
                                width: 34,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFB77A43),
                                      Color(0xFF754522),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF633A20),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(
                                      Icons.circle,
                                      color: Color(0xFFFFD477),
                                      size: 6,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),
                ],
              ),
            ),
          ),

          // Floating location card
          Positioned(
            left: 0,
            top: 38 + floatValue,
            child: floatingCard(
              icon: Icons.location_on_rounded,
              title: 'Prime Locations',
              subtitle: 'Near your university',
              color: AppColors.primary,
            ),
          ),

          // Verified hostel card
          Positioned(
            right: 0,
            top: 112 - floatValue,
            child: floatingCard(
              icon: Icons.verified_rounded,
              title: 'Verified Hostels',
              subtitle: 'Trusted listings',
              color: AppColors.success,
            ),
          ),

          // Budget card
          Positioned(
            left: 8,
            bottom: 5 - floatValue * 0.5,
            child: floatingCard(
              icon: Icons.account_balance_wallet,
              title: 'Budget Friendly',
              subtitle: 'Compare monthly rent',
              color: AppColors.warning,
            ),
          ),

          // Pulsing location indicator
          Positioned(
            right: 20,
            bottom: 30,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.9 + pulse.value * 0.2,
                  child: Container(
                    height: 39,
                    width: 39,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.13),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.near_me_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 730;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Animated brand logo
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: entrance,
                          curve: Curves.easeOutBack,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 47,
                              width: 47,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4775FF),
                                    AppColors.primary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.home_work_rounded,
                                color: Colors.white,
                                size: 27,
                              ),
                            ),

                            const SizedBox(width: 12),

                            const Text(
                              'StayNest',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.8,
                              ),
                            ),

                            const Spacer(),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Notifications',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Notifications coming soon.'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Profile',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Profile coming soon.'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: compact ? 12 : 25),

                      // Floating hostel animation
                      AnimatedBuilder(
                        animation: Listenable.merge([floating, pulse]),
                        builder: (context, child) {
                          final value = math.sin(floating.value * math.pi) * 8;

                          return hostelIllustration(value);
                        },
                      ),

                      // Animated welcome text
                      FadeTransition(
                        opacity: entrance,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.25),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: entrance,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'YOUR STUDENT LIFE, SIMPLIFIED',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 13),

                              const Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: 'Find Your Perfect\n'),
                                    TextSpan(
                                      text: 'Student Hostel.',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                style: TextStyle(
                                  fontSize: 32,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.2,
                                  color: AppColors.textPrimary,
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Explore verified hostels, compare facilities '
                                'and discover affordable student accommodation '
                                'in Rawalpindi and Islamabad.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Animated Get Started button
                      PrimaryButton(
                        text: opening
                            ? 'Opening your new home...'
                            : 'Get Started',
                        onPressed: openDoor,
                        icon: opening
                            ? Icons.door_sliding_rounded
                            : Icons.arrow_forward_rounded,
                        height: 58,
                        isBusy: opening,
                      ),

                      const SizedBox(height: 15),

                      const Center(
                        child: Text(
                          'A smarter way to find your next home.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



