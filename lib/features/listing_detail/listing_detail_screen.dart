import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/listing_model.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _showPriceTL = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listings = ref.watch(listingsProvider);
    final listing = listings.firstWhere(
      (l) => l.id == widget.listingId,
      orElse: () => listings.first,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Image gallery header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Share.share(
                    'CypCar\'da bu aracı gördüm: ${listing.title} — ${listing.priceInTL.toStringAsFixed(0)} TL',
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
              ),
              // Favorite
              GestureDetector(
                onTap: () {
                  final updated = listings.map((l) {
                    if (l.id == listing.id) return l.copyWith(isFavorited: !l.isFavorited);
                    return l;
                  }).toList();
                  ref.read(listingsProvider.notifier).state = updated;
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    listing.isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: listing.isFavorited ? AppColors.primary : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: listing.imageUrls.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) => Image.network(
                      listing.imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                        child: const Icon(Icons.directions_car, size: 80, color: AppColors.darkTextHint),
                      ),
                    ),
                  ),
                  // Page indicator
                  if (listing.imageUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedSmoothIndicator(
                          activeIndex: _currentPage,
                          count: listing.imageUrls.length,
                          effect: const WormEffect(
                            dotWidth: 8,
                            dotHeight: 8,
                            activeDotColor: AppColors.primary,
                            dotColor: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  // Photo count badge
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${_currentPage + 1}/${listing.imageUrls.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sold badge
                  if (listing.status == ListingStatus.sold)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: const Center(
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              'SATILDI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Emergency badge
                  if (listing.type == ListingType.emergency)
                    Positioned(
                      top: 60,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACİL SATILIK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  _TitlePriceSection(
                    listing: listing,
                    showTL: _showPriceTL,
                    onToggleCurrency: () => setState(() => _showPriceTL = !_showPriceTL),
                    isDark: isDark,
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Seller info
                  _SellerSection(listing: listing, isDark: isDark)
                      .animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Stats row
                  _StatsRow(listing: listing, isDark: isDark)
                      .animate().fadeIn(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Specs
                  _SpecsSection(listing: listing, isDark: isDark)
                      .animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  _DescriptionSection(listing: listing, isDark: isDark)
                      .animate().fadeIn(duration: 400.ms, delay: 250.ms),

                  const SizedBox(height: 24),

                  // Report button
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showReportDialog(context),
                      icon: const Icon(Icons.flag_outlined, size: 16),
                      label: const Text('İlanı Şikayet Et'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.darkTextHint,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ContactBar(listing: listing),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Şikayet Et'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ReportOption(text: 'Sahte ilan'),
            _ReportOption(text: 'Yanlış bilgi'),
            _ReportOption(text: 'Uygunsuz içerik'),
            _ReportOption(text: 'Diğer'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Şikayetiniz alındı, teşekkürler.')),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}

class _ReportOption extends StatelessWidget {
  final String text;
  const _ReportOption({required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.radio_button_unchecked),
      title: Text(text),
      dense: true,
      onTap: () {},
    );
  }
}

class _TitlePriceSection extends StatelessWidget {
  final ListingModel listing;
  final bool showTL;
  final VoidCallback onToggleCurrency;
  final bool isDark;

  const _TitlePriceSection({
    required this.listing,
    required this.showTL,
    required this.onToggleCurrency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final price = showTL ? listing.priceInTL : listing.priceInGBP;
    final symbol = showTL ? '₺' : '£';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
            Text(
              listing.location,
              style: TextStyle(
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatPrice(price)} $symbol',
                  style: TextStyle(
                    color: listing.type == ListingType.emergency
                        ? AppColors.emergencyRed
                        : AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (listing.isNegotiable)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pazarlığa açık',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onToggleCurrency,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  showTL ? '£ GBP\'ye çevir' : '₺ TL\'ye çevir',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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

class _SellerSection extends StatelessWidget {
  final ListingModel listing;
  final bool isDark;

  const _SellerSection({required this.listing, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Satıcı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: listing.sellerAvatarUrl != null
                  ? NetworkImage(listing.sellerAvatarUrl!)
                  : null,
              backgroundColor: AppColors.primaryContainer,
              child: listing.sellerAvatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        listing.sellerName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      if (listing.isSellerFounderMember) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium, color: AppColors.gold, size: 12),
                              SizedBox(width: 3),
                              Text(
                                'Kurucu',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Satıcı Profili',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.darkTextHint),
          ],
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ListingModel listing;
  final bool isDark;

  const _StatsRow({required this.listing, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          icon: Icons.remove_red_eye_outlined,
          label: 'Görüntülenme',
          value: '${listing.viewCount}',
          isDark: isDark,
        ),
        _StatItem(
          icon: Icons.access_time,
          label: 'İlan tarihi',
          value: _formatDate(listing.createdAt),
          isDark: isDark,
        ),
        if (listing.boostExpiresAt != null)
          _StatItem(
            icon: Icons.bolt,
            label: 'Boost bitiş',
            value: _formatDate(listing.boostExpiresAt!),
            isDark: isDark,
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 30) return '${diff.inDays} gün önce';
    return '${(diff.inDays / 30).floor()} ay önce';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecsSection extends StatelessWidget {
  final ListingModel listing;
  final bool isDark;

  const _SpecsSection({required this.listing, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final specs = [
      ('Marka', listing.brand, Icons.directions_car),
      ('Model', listing.model, Icons.car_repair),
      ('Yıl', '${listing.year}', Icons.calendar_today),
      ('Kilometre', '${listing.mileage ~/ 1000}.000 km', Icons.speed),
      ('Yakıt', listing.fuelType, Icons.local_gas_station),
      ('Vites', listing.transmission, Icons.settings),
      ('Kasa', listing.bodyType, Icons.category),
      ('Renk', listing.color, Icons.palette),
      ('Motor', '${listing.engineSize} lt', Icons.engineering),
      ('Güç', '${listing.horsepower} HP', Icons.flash_on),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Araç Bilgileri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: specs.map((spec) => _SpecItem(
            label: spec.$1,
            value: spec.$2,
            icon: spec.$3,
            isDark: isDark,
          )).toList(),
        ),
      ],
    );
  }
}

class _SpecItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _SpecItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final ListingModel listing;
  final bool isDark;

  const _DescriptionSection({required this.listing, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Açıklama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text(
          listing.description,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _ContactBar extends StatelessWidget {
  final ListingModel listing;

  const _ContactBar({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _callPhone(listing.sellerPhone),
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Ara'),
            ),
          ),
          if (listing.sellerWhatsApp != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openWhatsApp(listing.sellerWhatsApp!),
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: const Text('WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openWhatsApp(String phone) async {
    final number = phone.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
