import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../models/mock_data.dart';
import '../models/notification_model.dart';

// Theme provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// Auth provider
final isLoggedInProvider = StateProvider<bool>((ref) => false);

// Listings providers
final listingsProvider = StateProvider<List<ListingModel>>((ref) {
  return MockData.listings;
});

final boostedListingsProvider = Provider<List<ListingModel>>((ref) {
  return ref.watch(listingsProvider)
      .where((l) => l.type == ListingType.boost && l.status == ListingStatus.active)
      .toList();
});

final emergencyListingsProvider = Provider<List<ListingModel>>((ref) {
  return ref.watch(listingsProvider)
      .where((l) => l.type == ListingType.emergency && l.status == ListingStatus.active)
      .toList();
});

final normalListingsProvider = Provider<List<ListingModel>>((ref) {
  return ref.watch(listingsProvider)
      .where((l) => l.type == ListingType.normal && l.status == ListingStatus.active)
      .toList();
});

final favoritesProvider = Provider<List<ListingModel>>((ref) {
  return ref.watch(listingsProvider).where((l) => l.isFavorited).toList();
});

final favoritesCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).length;
});

// Notification provider
final notificationsProvider = StateProvider<List<NotificationModel>>((ref) {
  return MockData.notifications;
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

// Search filter provider
class SearchFilter {
  final String? brand;
  final String? series;
  final String? model;
  final String? fuelType;
  final String? transmission;
  final String? bodyType;
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final int? maxMileage;

  const SearchFilter({
    this.brand,
    this.series,
    this.model,
    this.fuelType,
    this.transmission,
    this.bodyType,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.maxMileage,
  });

  SearchFilter copyWith({
    String? brand,
    String? series,
    String? model,
    String? fuelType,
    String? transmission,
    String? bodyType,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    int? maxMileage,
    bool clearBrand = false,
    bool clearSeries = false,
    bool clearModel = false,
  }) {
    return SearchFilter(
      brand: clearBrand ? null : (brand ?? this.brand),
      series: clearSeries ? null : (series ?? this.series),
      model: clearModel ? null : (model ?? this.model),
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      bodyType: bodyType ?? this.bodyType,
      location: location ?? this.location,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      maxMileage: maxMileage ?? this.maxMileage,
    );
  }

  bool get isEmpty =>
      brand == null &&
      series == null &&
      model == null &&
      fuelType == null &&
      transmission == null &&
      bodyType == null &&
      location == null &&
      minPrice == null &&
      maxPrice == null &&
      minYear == null &&
      maxYear == null &&
      maxMileage == null;
}

final searchFilterProvider = StateProvider<SearchFilter>((ref) => const SearchFilter());

final searchResultsProvider = Provider<List<ListingModel>>((ref) {
  final filter = ref.watch(searchFilterProvider);
  final all = ref.watch(listingsProvider);

  return all.where((listing) {
    if (filter.brand != null && listing.brand != filter.brand) return false;
    if (filter.series != null && listing.series != filter.series) return false;
    if (filter.model != null && !listing.model.toLowerCase().contains(filter.model!.toLowerCase())) return false;
    if (filter.fuelType != null && listing.fuelType != filter.fuelType) return false;
    if (filter.transmission != null && listing.transmission != filter.transmission) return false;
    if (filter.bodyType != null && listing.bodyType != filter.bodyType) return false;
    if (filter.location != null && listing.location != filter.location) return false;
    if (filter.minPrice != null && listing.priceInTL < filter.minPrice!) return false;
    if (filter.maxPrice != null && listing.priceInTL > filter.maxPrice!) return false;
    if (filter.minYear != null && listing.year < filter.minYear!) return false;
    if (filter.maxYear != null && listing.year > filter.maxYear!) return false;
    if (filter.maxMileage != null && listing.mileage > filter.maxMileage!) return false;
    return true;
  }).toList();
});

// Selected currency provider (TL or GBP)
final selectedCurrencyProvider = StateProvider<String>((ref) => 'TL');

// Current nav index
final navIndexProvider = StateProvider<int>((ref) => 2); // Home is index 2
