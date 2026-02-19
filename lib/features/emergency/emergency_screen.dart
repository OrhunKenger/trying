import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/listing_model.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listings = ref.watch(emergencyListingsProvider);
    final currency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'Acil İlanlar',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.emergencyRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.emergencyRed.withOpacity(0.3)),
            ),
            child: Text(
              '${listings.length} ilan',
              style: const TextStyle(
                color: AppColors.emergencyRed,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.emergencyRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.emergencyRed.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.emergencyRed, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Bu ilanlar hızlı satış için öne çıkarılmış acil satılık araçlardır. Tüm fiyatlar pazarlığa açıktır.',
                    style: TextStyle(
                      color: AppColors.emergencyRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 8),

          // Listings
          Expanded(
            child: listings.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_outlined, size: 80, color: AppColors.darkTextHint),
                        SizedBox(height: 16),
                        Text(
                          'Şu an acil ilan bulunmuyor',
                          style: TextStyle(color: AppColors.darkTextHint, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _EmergencyListCard(
                        listing: listings[index],
                        currency: currency,
                        isDark: isDark,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                          .slideX(begin: -0.2, end: 0, duration: 400.ms, delay: (index * 100).ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyListCard extends ConsumerWidget {
  final ListingModel listing;
  final String currency;
  final bool isDark;

  const _EmergencyListCard({
    required this.listing,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.emergencyRed.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.emergencyRed.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              child: SizedBox(
                width: 130,
                height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      listing.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                        child: const Icon(Icons.directions_car, size: 40, color: AppColors.darkTextHint),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'ACİL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title.replaceAll(' - ACİL', '').replaceAll(' - ACİL SATILIK', ''),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final listings = ref.read(listingsProvider);
                            final updated = listings.map((l) {
                              if (l.id == listing.id) return l.copyWith(isFavorited: !l.isFavorited);
                              return l;
                            }).toList();
                            ref.read(listingsProvider.notifier).state = updated;
                          },
                          child: Icon(
                            listing.isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: listing.isFavorited ? AppColors.primary : AppColors.darkTextHint,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${listing.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                          ),
                        ),
                        Text(
                          ' · ${listing.mileage ~/ 1000}.000 km',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                        Text(
                          listing.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currency == 'TL'
                              ? '${_formatPrice(listing.priceInTL)} ₺'
                              : '£${_formatPrice(listing.priceInGBP)}',
                          style: const TextStyle(
                            color: AppColors.emergencyRed,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Pazarlık',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final thousands = (price / 1000).floor();
      final remainder = (price % 1000).round();
      if (remainder == 0) return '$thousands.000';
      return '$thousands.${remainder.toString().padLeft(3, '0')}';
    }
    return price.toStringAsFixed(0);
  }
}
