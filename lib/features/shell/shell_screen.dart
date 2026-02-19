import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';

class ShellScreen extends ConsumerWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navIndexProvider);
    final favCount = ref.watch(favoritesCountProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: _CypCarNavBar(
        currentIndex: navIndex,
        favCount: favCount,
        onTap: (index) {
          ref.read(navIndexProvider.notifier).state = index;
          switch (index) {
            case 0:
              context.go('/favorites');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/home');
              break;
            case 3:
              context.go('/emergency');
              break;
            case 5:
              context.go('/profile');
              break;
          }
        },
        onPostListing: () {
          context.push('/post-listing');
        },
      ),
    );
  }
}

class _CypCarNavBar extends StatelessWidget {
  final int currentIndex;
  final int favCount;
  final Function(int) onTap;
  final VoidCallback onPostListing;

  const _CypCarNavBar({
    required this.currentIndex,
    required this.favCount,
    required this.onTap,
    required this.onPostListing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightBackground;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: 'Favoriler',
                isActive: currentIndex == 0,
                badge: favCount > 0 ? favCount.toString() : null,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: 'Ara',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // Ana Sayfa - öne çıkmış buton
              _HomeNavItem(
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              // Acil - öne çıkmış buton
              _EmergencyNavItem(
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              // İlan Ver
              _PostListingNavItem(onTap: onPostListing),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
                isActive: currentIndex == 5,
                onTap: () => onTap(5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.darkTextSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            badges.Badge(
              showBadge: badge != null,
              badgeContent: Text(
                badge ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: AppColors.primary,
                padding: EdgeInsets.all(4),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _HomeNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -8),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryDark : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
              ),
            ),
            const Text(
              'Ana Sayfa',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _EmergencyNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -8),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryDark : AppColors.emergencyRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emergencyRed.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(height: 0),
            const Text(
              'Acil',
              style: TextStyle(
                color: AppColors.emergencyRed,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostListingNavItem extends StatelessWidget {
  final VoidCallback onTap;

  const _PostListingNavItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 2),
            const Text(
              'İlan Ver',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
