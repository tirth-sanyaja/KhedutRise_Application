class FarmerModel {
  final String id;
  final String name;
  final String fatherName;
  final String phone;
  final String aadhaar;
  final String location;
  final String village;
  final String district;
  final String state;
  final String pinCode;
  final String landAcres;
  final String soilType;
  final String waterSource;
  final String email;
  final String password;
  final String currentCrop;
  final String sowingDate;
  final String harvestDate;

  const FarmerModel({
    required this.id,
    required this.name,
    this.fatherName = '',
    required this.phone,
    this.aadhaar = '',
    this.location = '',
    this.village = '',
    this.district = '',
    this.state = 'Gujarat',
    this.pinCode = '',
    this.landAcres = '5.0 Acres',
    this.soilType = 'Black Soil',
    this.waterSource = 'Borewell',
    this.email = '',
    this.password = '1234',
    this.currentCrop = 'Cotton',
    this.sowingDate = '15 June 2026',
    this.harvestDate = '15 Oct 2026 (Day 45/120)',
  });

  /// Derive initials dynamically from the name (e.g. "Ramesh Patel" -> "RP")
  String get initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'KR';
    final parts = clean
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Short display name (e.g. "Tirthbhai" or "Ramesh Patel")
  String get displayName {
    final clean = name.trim();
    if (clean.isEmpty) return 'Khedut Farmer';
    return clean;
  }

  /// Computed location string
  String get displayLocation {
    if (location.isNotEmpty) return location;
    final parts = [
      village,
      district,
      state,
    ].where((s) => s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Gujarat, India';
  }

  FarmerModel copyWith({
    String? id,
    String? name,
    String? fatherName,
    String? phone,
    String? aadhaar,
    String? location,
    String? village,
    String? district,
    String? state,
    String? pinCode,
    String? landAcres,
    String? soilType,
    String? waterSource,
    String? email,
    String? password,
    String? currentCrop,
    String? sowingDate,
    String? harvestDate,
  }) {
    return FarmerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      phone: phone ?? this.phone,
      aadhaar: aadhaar ?? this.aadhaar,
      location: location ?? this.location,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      landAcres: landAcres ?? this.landAcres,
      soilType: soilType ?? this.soilType,
      waterSource: waterSource ?? this.waterSource,
      email: email ?? this.email,
      password: password ?? this.password,
      currentCrop: currentCrop ?? this.currentCrop,
      sowingDate: sowingDate ?? this.sowingDate,
      harvestDate: harvestDate ?? this.harvestDate,
    );
  }
}
