enum ListingType { normal, boost, emergency }
enum ListingStatus { pending, active, sold, expired, rejected }

class ListingModel {
  final String id;
  final String title;
  final String brand;
  final String series;
  final String model;
  final int year;
  final int mileage;
  final double priceInTL;
  final String fuelType;
  final String transmission;
  final String bodyType;
  final String color;
  final String engineSize;
  final int horsepower;
  final String location;
  final String description;
  final List<String> imageUrls;
  final ListingType type;
  final ListingStatus status;
  final bool isNegotiable;
  final bool isFavorited;
  final int viewCount;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String? sellerWhatsApp;
  final DateTime createdAt;
  final DateTime? boostExpiresAt;
  final String? sellerAvatarUrl;
  final bool isSellerFounderMember;

  const ListingModel({
    required this.id,
    required this.title,
    required this.brand,
    required this.series,
    required this.model,
    required this.year,
    required this.mileage,
    required this.priceInTL,
    required this.fuelType,
    required this.transmission,
    required this.bodyType,
    required this.color,
    required this.engineSize,
    required this.horsepower,
    required this.location,
    required this.description,
    required this.imageUrls,
    required this.type,
    required this.status,
    required this.isNegotiable,
    required this.isFavorited,
    required this.viewCount,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    this.sellerWhatsApp,
    required this.createdAt,
    this.boostExpiresAt,
    this.sellerAvatarUrl,
    required this.isSellerFounderMember,
  });

  ListingModel copyWith({
    bool? isFavorited,
    ListingStatus? status,
    ListingType? type,
    DateTime? boostExpiresAt,
    int? viewCount,
  }) {
    return ListingModel(
      id: id,
      title: title,
      brand: brand,
      series: series,
      model: model,
      year: year,
      mileage: mileage,
      priceInTL: priceInTL,
      fuelType: fuelType,
      transmission: transmission,
      bodyType: bodyType,
      color: color,
      engineSize: engineSize,
      horsepower: horsepower,
      location: location,
      description: description,
      imageUrls: imageUrls,
      type: type ?? this.type,
      status: status ?? this.status,
      isNegotiable: isNegotiable,
      isFavorited: isFavorited ?? this.isFavorited,
      viewCount: viewCount ?? this.viewCount,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      sellerWhatsApp: sellerWhatsApp,
      createdAt: createdAt,
      boostExpiresAt: boostExpiresAt ?? this.boostExpiresAt,
      sellerAvatarUrl: sellerAvatarUrl,
      isSellerFounderMember: isSellerFounderMember,
    );
  }

  double get priceInGBP => priceInTL / 42.5;
}
