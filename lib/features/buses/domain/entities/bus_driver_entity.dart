class BusDriverEntity {
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final List<String> assignedRoutes;
  final bool isActive;
  final DateTime createdAt;

  const BusDriverEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.licenseNumber,
    this.licenseExpiry,
    required this.assignedRoutes,
    required this.isActive,
    required this.createdAt,
  });

  bool get isLicenseValid {
    if (licenseExpiry == null) return false;
    return licenseExpiry!.isAfter(DateTime.now());
  }

  BusDriverEntity copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? licenseNumber,
    DateTime? licenseExpiry,
    List<String>? assignedRoutes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BusDriverEntity(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      assignedRoutes: assignedRoutes ?? this.assignedRoutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
