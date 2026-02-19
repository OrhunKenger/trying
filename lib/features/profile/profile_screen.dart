import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/mock_data.dart';
import '../../shared/widgets/listing_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final user = MockData.currentUser;
    final myListings = ref.watch(listingsProvider)
        .where((l) => l.sellerId == 'u1')
        .toList();

    if (!isLoggedIn) {
      return _GuestView(isDark: isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: false,
            pinned: true,
            expandedHeight: 260,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            title: innerBoxIsScrolled ? const Text('Profilim') : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _showSettingsSheet(context, isDark),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(user: user, isDark: isDark),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabBar: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'İlanlarım (${myListings.length})'),
                  const Tab(text: 'Bilgilerim'),
                ],
              ),
              isDark: isDark,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // My listings
            myListings.isEmpty
                ? const Center(child: Text('Henüz ilan vermediniz'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: myListings.length,
                    itemBuilder: (context, index) => ListingCard(
                      listing: myListings[index],
                      isBoost: myListings[index].type.name == 'boost',
                    ),
                  ),

            // Account info
            _AccountInfoView(user: user, isDark: isDark),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _SettingItem(
              icon: Icons.dark_mode_outlined,
              label: isDark ? 'Light Mod\'a Geç' : 'Dark Mod\'a Geç',
              onTap: () {
                ref.read(themeModeProvider.notifier).state =
                    isDark ? ThemeMode.light : ThemeMode.dark;
                Navigator.pop(context);
              },
            ),
            _SettingItem(
              icon: Icons.language,
              label: 'Dil Ayarları',
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.security,
              label: 'Güvenlik',
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.help_outline,
              label: 'Yardım',
              onTap: () {},
            ),
            const Divider(),
            _SettingItem(
              icon: Icons.logout,
              label: 'Çıkış Yap',
              isDestructive: true,
              onTap: () {
                ref.read(isLoggedInProvider.notifier).state = false;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _ProfileHeader({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    backgroundColor: AppColors.primaryContainer,
                    child: user.avatarUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 44)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        if (user.isFounderMember) ...[
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
                                  'Kurucu Üye',
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
                      user.email,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Üye: ${user.memberSince}',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatChip(label: 'Toplam İlan', value: '${user.totalListings}'),
              const SizedBox(width: 12),
              _StatChip(label: 'Aktif', value: '${user.activeListings}'),
              const SizedBox(width: 12),
              _StatChip(label: 'Satılan', value: '${user.totalListings - user.activeListings}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountInfoView extends StatefulWidget {
  final dynamic user;
  final bool isDark;

  const _AccountInfoView({required this.user, required this.isDark});

  @override
  State<_AccountInfoView> createState() => _AccountInfoViewState();
}

class _AccountInfoViewState extends State<_AccountInfoView> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kişisel Bilgiler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton.icon(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 16),
                label: Text(_isEditing ? 'Kaydet' : 'Düzenle'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoField(label: 'Ad Soyad', value: widget.user.name, isEditable: _isEditing, isDark: widget.isDark),
          const SizedBox(height: 12),
          _InfoField(label: 'E-posta', value: widget.user.email, isEditable: _isEditing, isDark: widget.isDark),
          const SizedBox(height: 12),
          _InfoField(label: 'Telefon', value: widget.user.phone, isEditable: false, isDark: widget.isDark),
          const SizedBox(height: 24),
          const Text('İlan Yönetimi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _ManagementItem(
            icon: Icons.list_alt,
            title: 'Tüm İlanlarım',
            subtitle: '${widget.user.totalListings} ilan',
            isDark: widget.isDark,
          ),
          const SizedBox(height: 8),
          _ManagementItem(
            icon: Icons.refresh,
            title: 'Yenileme Gerektirenler',
            subtitle: '1 ilan 15 gün içinde dolacak',
            isDark: widget.isDark,
            isWarning: true,
          ),
          const SizedBox(height: 8),
          _ManagementItem(
            icon: Icons.bolt,
            title: 'Boost Yönetimi',
            subtitle: '2 aktif boost',
            isDark: widget.isDark,
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label, value;
  final bool isEditable, isDark;

  const _InfoField({
    required this.label,
    required this.value,
    required this.isEditable,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEditable ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isEditable ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (isEditable)
            const Icon(Icons.edit, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _ManagementItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool isDark, isWarning;

  const _ManagementItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? AppColors.warning.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isWarning ? AppColors.warning : AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isWarning ? AppColors.warning : (isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.darkTextHint),
        ],
      ),
    );
  }
}

class _GuestView extends StatelessWidget {
  final bool isDark;

  const _GuestView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 100,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              const Text(
                'Giriş Yapın',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'İlan vermek, favorileri yönetmek ve daha fazlası için giriş yapın.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/auth'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Giriş Yap / Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : null),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppColors.error : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  const _TabBarDelegate({required this.tabBar, required this.isDark});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
