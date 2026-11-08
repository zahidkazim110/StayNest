import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hostel.dart';

class HostelReviewsScreen extends StatefulWidget {
  final Hostel hostel;
  const HostelReviewsScreen({super.key, required this.hostel});

  @override
  State<HostelReviewsScreen> createState() => _HostelReviewsScreenState();
}

class _HostelReviewsScreenState extends State<HostelReviewsScreen> {
  final commentController = TextEditingController();
  int selectedRating = 5;
  List<_LocalReview> reviews = [];
  bool loading = true;

  String get _storageKey {
    final slug = widget.hostel.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return 'staynest_reviews_$slug';
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final loaded = raw.map((entry) {
      final parts = entry.split('|');
      return _LocalReview(
        rating: int.tryParse(parts.first) ?? 5,
        comment: parts.length > 1 ? parts.sublist(1).join('|') : '',
      );
    }).toList();
    if (!mounted) return;
    setState(() {
      reviews = loaded;
      loading = false;
    });
  }

  Future<void> _submitReview() async {
    final comment = commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write a short review first.')));
      return;
    }
    final updated = [_LocalReview(rating: selectedRating, comment: comment), ...reviews];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, updated.map((item) => '${item.rating}|${item.comment}').toList());
    if (!mounted) return;
    setState(() {
      reviews = updated;
      commentController.clear();
      selectedRating = 5;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your demo review was saved on this device.')));
  }

  @override
  Widget build(BuildContext context) {
    final average = reviews.isEmpty ? null : reviews.map((e) => e.rating).reduce((a, b) => a + b) / reviews.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reviews & Ratings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.hostel.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: AppColors.gold),
                      const SizedBox(width: 5),
                      Text(average == null ? 'No local reviews yet' : '${average.toStringAsFixed(1)} / 5', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const Spacer(),
                      Text('${reviews.length} review(s)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 20),
                const Text('Write a review', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Your rating', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 5),
                    Row(children: List.generate(5, (index) => IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => selectedRating = index + 1),
                      icon: Icon(index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.gold, size: 29),
                    ))),
                    TextField(
                      controller: commentController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 400,
                      decoration: InputDecoration(hintText: 'Share your experience...', filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border))),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _submitReview, icon: const Icon(Icons.rate_review_outlined), label: const Text('Submit review'))),
                  ]),
                ),
                const SizedBox(height: 20),
                const Text('Student reviews', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                if (reviews.isEmpty)
                  const Padding(padding: EdgeInsets.all(18), child: Text('No reviews have been added on this device yet.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)))
                else
                  ...reviews.map((review) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const CircleAvatar(radius: 15, backgroundColor: AppColors.primaryLight, child: Icon(Icons.person, size: 17, color: AppColors.primary)),
                        const SizedBox(width: 9),
                        const Expanded(child: Text('StayNest student', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                        ...List.generate(review.rating, (_) => const Icon(Icons.star_rounded, size: 14, color: AppColors.gold)),
                      ]),
                      const SizedBox(height: 10),
                      Text(review.comment, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary)),
                    ]),
                  )),
                const SizedBox(height: 8),
                const Text('Reviews are local demo content and are not shared with hostel owners or other users.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
    );
  }
}

class _LocalReview {
  final int rating;
  final String comment;
  const _LocalReview({required this.rating, required this.comment});
}
