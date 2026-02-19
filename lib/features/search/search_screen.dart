import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/mock_data.dart';
import '../../shared/widgets/listing_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  int _step = 0; // 0: brand, 1: series, 2: model, 3: results+filter
  bool _showFilters = false;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(searchFilterProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Araç Ara'),
        actions: [
          if (filter.brand != null)
            TextButton(
              onPressed: () {
                ref.read(searchFilterProvider.notifier).state = const SearchFilter();
                setState(() => _step = 0);
              },
              child: const Text(
                'Temizle',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress breadcrumb
          if (filter.brand != null)
            _BreadCrumb(
              brand: filter.brand,
              series: filter.series,
              model: filter.model,
              onBrandTap: () {
                ref.read(searchFilterProvider.notifier).state = const SearchFilter();
                setState(() => _step = 0);
              },
              onSeriesTap: () {
                ref.read(searchFilterProvider.notifier).update(
                  (s) => s.copyWith(clearSeries: true, clearModel: true),
                );
                setState(() => _step = 1);
              },
            ).animate().fadeIn(duration: 300.ms),

          Expanded(
            child: _step == 0
                ? _BrandSelector(
                    isDark: isDark,
                    onSelect: (brand) {
                      ref.read(searchFilterProvider.notifier).update(
                            (s) => s.copyWith(brand: brand, clearSeries: true, clearModel: true),
                          );
                      setState(() => _step = 1);
                    },
                  )
                : _step == 1
                    ? _SeriesSelector(
                        isDark: isDark,
                        brand: filter.brand!,
                        onSelect: (series) {
                          ref.read(searchFilterProvider.notifier).update(
                                (s) => s.copyWith(series: series, clearModel: true),
                              );
                          setState(() => _step = 3);
                        },
                        onSkip: () => setState(() => _step = 3),
                      )
                    : _ResultsView(
                        isDark: isDark,
                        results: results,
                        showFilters: _showFilters,
                        onToggleFilters: () => setState(() => _showFilters = !_showFilters),
                        scrollController: _scrollController,
                      ),
          ),
        ],
      ),
    );
  }
}

class _BreadCrumb extends StatelessWidget {
  final String? brand;
  final String? series;
  final String? model;
  final VoidCallback onBrandTap;
  final VoidCallback onSeriesTap;

  const _BreadCrumb({
    required this.brand,
    required this.series,
    required this.model,
    required this.onBrandTap,
    required this.onSeriesTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Row(
        children: [
          if (brand != null) ...[
            GestureDetector(
              onTap: onBrandTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  brand!,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (series != null) ...[
            const Icon(Icons.chevron_right, size: 16, color: AppColors.darkTextHint),
            GestureDetector(
              onTap: onSeriesTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  series!,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BrandSelector extends StatefulWidget {
  final bool isDark;
  final Function(String) onSelect;

  const _BrandSelector({required this.isDark, required this.onSelect});

  @override
  State<_BrandSelector> createState() => _BrandSelectorState();
}

class _BrandSelectorState extends State<_BrandSelector> {
  String _search = '';

  List<String> get _filtered => MockData.brands
      .where((b) => b.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Marka Seçin',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Marka ara...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final brand = _filtered[index];
              return GestureDetector(
                onTap: () => widget.onSelect(brand),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    brand,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (index * 30).ms)
                  .scale(begin: const Offset(0.9, 0.9), duration: 300.ms, delay: (index * 30).ms);
            },
          ),
        ),
      ],
    );
  }
}

class _SeriesSelector extends StatelessWidget {
  final bool isDark;
  final String brand;
  final Function(String) onSelect;
  final VoidCallback onSkip;

  const _SeriesSelector({
    required this.isDark,
    required this.brand,
    required this.onSelect,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final seriesList = MockData.brandSeries[brand] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$brand — Seri Seçin',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${seriesList.length} seri mevcut',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onSkip,
                child: const Text('Tümünü Gör'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: seriesList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onSelect(seriesList[index]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        seriesList[index],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppColors.darkTextHint),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms);
            },
          ),
        ),
      ],
    );
  }
}

class _ResultsView extends ConsumerWidget {
  final bool isDark;
  final List results;
  final bool showFilters;
  final VoidCallback onToggleFilters;
  final ScrollController scrollController;

  const _ResultsView({
    required this.isDark,
    required this.results,
    required this.showFilters,
    required this.onToggleFilters,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Text(
                '${results.length} araç bulundu',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onToggleFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: showFilters
                        ? AppColors.primaryContainer
                        : (isDark ? AppColors.darkSurface2 : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: showFilters
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune,
                        size: 18,
                        color: showFilters ? AppColors.primaryLight : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Filtrele',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: showFilters ? AppColors.primaryLight : null,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Filters panel
        if (showFilters)
          _FiltersPanel(isDark: isDark, ref: ref, filter: filter),

        // Results grid
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 80, color: AppColors.darkTextHint),
                      const SizedBox(height: 16),
                      const Text(
                        'Araç bulunamadı',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Filtreleri değiştirmeyi deneyin',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return ListingCard(listing: results[index] as dynamic)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (index * 60).ms);
                  },
                ),
        ),
      ],
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  final bool isDark;
  final WidgetRef ref;
  final SearchFilter filter;

  const _FiltersPanel({required this.isDark, required this.ref, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detaylı Filtrele', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  label: 'Yakıt Tipi',
                  items: MockData.fuelTypes,
                  value: filter.fuelType,
                  isDark: isDark,
                  onChanged: (v) => ref.read(searchFilterProvider.notifier).update(
                    (s) => s.copyWith(fuelType: v),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterDropdown(
                  label: 'Vites',
                  items: MockData.transmissions,
                  value: filter.transmission,
                  isDark: isDark,
                  onChanged: (v) => ref.read(searchFilterProvider.notifier).update(
                    (s) => s.copyWith(transmission: v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  label: 'Kasa Tipi',
                  items: MockData.bodyTypes,
                  value: filter.bodyType,
                  isDark: isDark,
                  onChanged: (v) => ref.read(searchFilterProvider.notifier).update(
                    (s) => s.copyWith(bodyType: v),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterDropdown(
                  label: 'Şehir',
                  items: MockData.locations,
                  value: filter.location,
                  isDark: isDark,
                  onChanged: (v) => ref.read(searchFilterProvider.notifier).update(
                    (s) => s.copyWith(location: v),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0);
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final bool isDark;
  final Function(String?) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      dropdownColor: isDark ? AppColors.darkSurface2 : AppColors.lightBackground,
      items: [
        DropdownMenuItem(value: null, child: Text('Tümü', style: TextStyle(fontSize: 13))),
        ...items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)))),
      ],
      onChanged: onChanged,
    );
  }
}
