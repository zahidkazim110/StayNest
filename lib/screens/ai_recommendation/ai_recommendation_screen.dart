import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';
import '../hostel_details/hostel_details_screen.dart';

class AIRecommendationScreen extends StatefulWidget {
  final List<Hostel> hostels;

  const AIRecommendationScreen({super.key, required this.hostels});

  @override
  State<AIRecommendationScreen> createState() => _AIRecommendationScreenState();
}

class _AIRecommendationScreenState extends State<AIRecommendationScreen> {
  String selectedCity = 'Islamabad';
  String selectedRoom = 'Any';
  double maxBudget = 20000;

  final Set<String> selectedFacilities = {};

  final List<String> facilities = ['Wi-Fi', 'Laundry', 'Mess', 'AC'];

  List<_Recommendation> get recommendations {
    final results = widget.hostels
        .where(
          (hostel) =>
              hostel.area.toLowerCase().contains(selectedCity.toLowerCase()),
        )
        .map((hostel) {
          int score = 35;
          final reasons = <String>[];

          reasons.add('Available in $selectedCity');

          if (selectedRoom == 'Any') {
            score += 25;
            reasons.add('Room preference is flexible');
          } else if (hostel.roomTypes.contains(selectedRoom)) {
            score += 25;
            reasons.add('$selectedRoom room available');
          } else {
            reasons.add('$selectedRoom room not listed');
          }

          if (hostel.monthlyRent <= maxBudget) {
            score += 25;
            reasons.add('Within your monthly budget');
          } else {
            final difference = hostel.monthlyRent - maxBudget;
            final penalty = ((difference / maxBudget) * 25).round().clamp(
              0,
              25,
            );
            score += 25 - penalty;
            reasons.add('Above your selected budget');
          }

          if (selectedFacilities.isEmpty) {
            score += 15;
            reasons.add('No specific facilities required');
          } else {
            int matched = 0;

            for (final facility in selectedFacilities) {
              if (hostel.facilities.contains(facility)) {
                matched++;
              }
            }

            score += ((matched / selectedFacilities.length) * 15).round();

            if (matched > 0) {
              reasons.add('$matched preferred facility/facilities available');
            } else {
              reasons.add('Preferred facilities not listed');
            }
          }

          return _Recommendation(
            hostel: hostel,
            score: score.clamp(0, 100),
            reasons: reasons,
          );
        })
        .toList();

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  void generateRecommendations() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final results = recommendations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Hostel Recommendations'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 30),
                SizedBox(height: 12),
                Text(
                  'Find Your Ideal Hostel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tell us your preferences and discover suitable student accommodation.',
                  style: TextStyle(color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionTitle('Choose Your City'),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: selectedCity,
            decoration: _inputDecoration('Select city'),
            items: const [
              DropdownMenuItem(value: 'Islamabad', child: Text('Islamabad')),
              DropdownMenuItem(value: 'Rawalpindi', child: Text('Rawalpindi')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedCity = value);
              }
            },
          ),

          const SizedBox(height: 22),
          _sectionTitle('Maximum Monthly Budget'),
          Text(
            'PKR ${maxBudget.round()}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          Slider(
            value: maxBudget,
            min: 5000,
            max: 40000,
            divisions: 35,
            activeColor: AppColors.primary,
            label: 'PKR ${maxBudget.round()}',
            onChanged: (value) {
              setState(() => maxBudget = value);
            },
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('PKR 5,000'), Text('PKR 40,000')],
          ),

          const SizedBox(height: 22),
          _sectionTitle('Preferred Room Type'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['Any', 'Single', 'Double', 'Shared'].map((room) {
              return ChoiceChip(
                label: Text(room),
                selected: selectedRoom == room,
                selectedColor: AppColors.primaryLight,
                onSelected: (_) {
                  setState(() => selectedRoom = room);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 22),
          _sectionTitle('Required Facilities'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 5,
            children: facilities.map((facility) {
              return FilterChip(
                label: Text(facility),
                selected: selectedFacilities.contains(facility),
                selectedColor: AppColors.primaryLight,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedFacilities.add(facility);
                    } else {
                      selectedFacilities.remove(facility);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: generateRecommendations,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Get Recommendations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),
          _sectionTitle('Recommended Hostels'),
          const SizedBox(height: 5),
          Text(
            '${results.length} hostel(s) found in $selectedCity',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),

          if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No sample hostels are currently available in this city.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ...results.map(_recommendationCard),
        ],
      ),
    );
  }

  Widget _recommendationCard(_Recommendation result) {
    final hostel = result.hostel;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hostel.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${result.score}% Match',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hostel.area,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'PKR ${hostel.monthlyRent} / month',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Why this hostel matches:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ...result.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HostelDetailsScreen(hostel: hostel),
                  ),
                );
              },
              child: const Text('View Hostel Details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }
}

class _Recommendation {
  final Hostel hostel;
  final int score;
  final List<String> reasons;

  const _Recommendation({
    required this.hostel,
    required this.score,
    required this.reasons,
  });
}
