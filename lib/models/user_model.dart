class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final bool isFounderMember;
  final String memberSince;
  final int totalListings;
  final int activeListings;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.isFounderMember,
    required this.memberSince,
    required this.totalListings,
    required this.activeListings,
  });
}
