import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HostelCard extends StatelessWidget {
  final String name;
  final String location;
  final String price;
  final double rating;
  final String imageUrl;
  final VoidCallback onTap;

  const HostelCard({
    super.key,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14172B2A),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: SizedBox(
                  height: 174,
                  width: double.infinity,
                  child: imageUrl.trim().isEmpty
                      ? _imagePlaceholder()
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _imagePlaceholder(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _imagePlaceholder();
                          },
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.3,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _ratingBadge(),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MONTHLY RENT',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 9,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                price,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
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

  Widget _ratingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 15),
          const SizedBox(width: 4),
          Text(
            rating > 0 ? rating.toStringAsFixed(1) : 'New',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE1F3EF), Color(0xFFB8DCD2), Color(0xFF9BCFC2)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -35,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.24),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -65,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.apartment_rounded,
                  color: AppColors.primary,
                  size: 55,
                ),
                SizedBox(height: 8),
                Text(
                  'STUDENT ACCOMMODATION',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 9,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
