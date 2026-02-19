import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/listing_card.dart';
import '../../models/listing_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 200;
      if (show != _showFab) setState(() => _showFab = show);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boosted = ref.watch(boostedListingsProvider);
    final emergency = ref.watch(emergencyListingsProvider);
    final normal = ref.watch(normalListingsProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    final unread = ref.watch(unreadNotificationsCountProvider);

    // Mix emergency and normal listings
    final mixedListings = _buildMixedFeed(emergency, normal);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_car, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CypCar',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            actions: [
              // Currency toggle
              GestureDetector(
                onTap: () {
                  ref.read(selectedCurrencyProvider.notifier).state =
                      currency == 'TL' ? 'GBP' : 'TL';
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    currency == 'TL' ? '₺ TL' : '£ GBP',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              // Theme toggle
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).state =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
              // Notifications
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Quick search bar
                  GestureDetector(
                    onTap: () => context.go('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Marka, model veya anahtar kelime...',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // BOOST Section
                  if (boosted.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Öne Çıkan İlanlar',
                      subtitle: '${boosted.length}/12 slot dolu',
                      icon: Icons.bolt,
                      iconColor: AppColors.gold,
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: boosted.length,
                      itemBuilder: (context, index) {
                        return ListingCard(
                          listing: boosted[index],
                          isBoost: true,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 80).ms)
                            .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (index * 80).ms);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Mixed Feed (Emergency + Normal)
                  _SectionHeader(
                    title: 'Tüm İlanlar',
                    subtitle: '${mixedListings.length} ilan',
                    icon: Icons.list_alt,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: mixedListings.length,
                    itemBuilder: (context, index) {
                      final listing = mixedListings[index];
                      return _buildFeedCard(listing, index);
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton.small(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            ).animate().scale(duration: 200.ms)
          : null,
    );
  }

  List<ListingModel> _buildMixedFeed(
      List<ListingModel> emergency, List<ListingModel> normal) {
    // Emergency ilanları arasına serpiştir
    final result = <ListingModel>[];
    final emergencyList = List<ListingModel>.from(emergency);
    final normalList = List<ListingModel>.from(normal);

    int normalCount = 0;
    int emergencyIndex = 0;

    for (final n in normalList) {
      result.add(n);
      normalCount++;
      // Her 2-3 normal ilandan sonra bir acil ilan ekle
      if (normalCount >= 2 && emergencyIndex < emergencyList.length) {
        result.add(emergencyList[emergencyIndex++]);
        normalCount = 0;
      }
    }

    // Kalan acil ilanları ekle
    while (emergencyIndex < emergencyList.length) {
      result.add(emergencyList[emergencyIndex++]);
    }

    return result;
  }

  Widget _buildFeedCard(ListingModel listing, int index) {
    if (listing.type == ListingType.emergency) {
      return _EmergencyFeedCard(listing: listing)
          .animate()
          .fadeIn(duration: 400.ms, delay: (index * 60).ms)
          .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (index * 60).ms);
    }
    return ListingCard(listing: listing)
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 60).ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (index * 60).ms);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
          ),
        ),
      ],
    );
  }
}

class _EmergencyFeedCard extends ConsumerWidget {
  final ListingModel listing;

  const _EmergencyFeedCard({required this.listing});

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
            color: AppColors.emergencyRed.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.emergencyRed.withOpacity(0.12),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        child: const Icon(Icons.directions_car, size: 50, color: AppColors.darkTextHint),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ACİL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      final listings = ref.read(listingsProvider);
                      final updated = listings.map((l) {
                        if (l.id == listing.id) return l.copyWith(isFavorited: !l.isFavorited);
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
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${listing.brand} ${listing.series}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${listing.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                        ),
                      ),
                      const Text(' · '),
                      Text(
                        listing.fuelType,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 2),
                  const Text(
                    'Pazarlığa açık',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
