import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/listing_model.dart';
import '../../providers/app_providers.dart';

class ListingCard extends ConsumerWidget {
  final ListingModel listing;
  final bool isBoost;

  const ListingCard({
    super.key,
    required this.listing,
    this.isBoost = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = ref.watch(selectedCurrencyProvider);

    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBoost
                ? AppColors.primary.withOpacity(0.5)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isBoost ? 1.5 : 0.5,
          ),
          boxShadow: isBoost
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      listing.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                        child: const Icon(
                          Icons.directions_car,
                          size: 60,
                          color: AppColors.darkTextHint,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Boost badge
                if (isBoost)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _BoostBadge(),
                  ),
                // Photo count
                if (listing.imageUrls.length > 1)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${listing.imageUrls.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Sold overlay
                if (listing.status == ListingStatus.sold)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: const Center(
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            'SATILDI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: _FavoriteButton(listing: listing, ref: ref),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Year, km
                  Row(
                    children: [
                      _Tag(
                        text: '${listing.year}',
                        icon: Icons.calendar_today,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _Tag(
                        text: '${_formatNumber(listing.mileage)} km',
                        icon: Icons.speed,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _Tag(
                        text: listing.fuelType,
                        icon: Icons.local_gas_station,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency == 'TL'
                                ? '${_formatPrice(listing.priceInTL)} ₺'
                                : '£${_formatPrice(listing.priceInGBP)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (listing.isNegotiable)
                            const Text(
                              'Pazarlığa açık',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                          ),
                          Text(
                            listing.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(0)}.${(n % 1000).toString().padLeft(3, '0')}';
    }
    return n.toString();
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(2)} M';
    } else if (price >= 1000) {
      final thousands = (price / 1000).floor();
      final remainder = (price % 1000).round();
      if (remainder == 0) return '$thousands.000';
      return '$thousands.${remainder.toString().padLeft(3, '0')}';
    }
    return price.toStringAsFixed(0);
  }
}

class _BoostBadge extends StatefulWidget {
  @override
  State<_BoostBadge> createState() => _BoostBadgeState();
}

class _BoostBadgeState extends State<_BoostBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_glow.value * 0.8),
              blurRadius: 8 + 4 * _glow.value,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: Colors.white, size: 12),
            SizedBox(width: 3),
            Text(
              'BOOST',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final ListingModel listing;
  final WidgetRef ref;

  const _FavoriteButton({required this.listing, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final listings = ref.read(listingsProvider);
        final updated = listings.map((l) {
          if (l.id == listing.id) {
            return l.copyWith(isFavorited: !l.isFavorited);
          }
          return l;
        }).toList();
        ref.read(listingsProvider.notifier).state = updated;
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          listing.isFavorited ? Icons.favorite : Icons.favorite_border,
          color: listing.isFavorited ? AppColors.primary : Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isDark;

  const _Tag({required this.text, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
