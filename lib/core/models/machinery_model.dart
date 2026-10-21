enum BookingStatus { confirmed, active, completed, cancelled }

enum MachineryAvailability { available, booked, unavailable }

class MachineryProvider {
  final String id;
  final String name;
  final String phone;
  final String village;
  final String district;
  final double rating;
  final int totalBookings;
  final bool isVerified;

  const MachineryProvider({
    required this.id,
    required this.name,
    required this.phone,
    required this.village,
    required this.district,
    this.rating = 4.8,
    this.totalBookings = 40,
    this.isVerified = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'village': village,
    'district': district,
    'rating': rating,
    'totalBookings': totalBookings,
    'isVerified': isVerified,
  };

  factory MachineryProvider.fromJson(Map<String, dynamic> json) {
    return MachineryProvider(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      village: json['village'] as String? ?? '',
      district: json['district'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 40,
      isVerified: json['isVerified'] as bool? ?? true,
    );
  }
}

class MachineryItem {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String
  category; // 'Tractor', 'Rotavator', 'Cultivator', 'Seed Drill', 'Harvester', 'Other Farm Machinery'
  final String hp;
  final MachineryProvider provider;
  final String location;
  final double distanceKm;
  final int hourlyRate;
  final int dailyRate;
  final String rentalUnit;
  final String implementsAttached;
  final bool withDriver;
  final bool fuelIncluded;
  final MachineryAvailability availability;
  final String badge;
  final String description;
  final Map<String, String> specifications;

  const MachineryItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.category,
    required this.hp,
    required this.provider,
    required this.location,
    required this.distanceKm,
    required this.hourlyRate,
    required this.dailyRate,
    this.rentalUnit = 'per hour',
    required this.implementsAttached,
    this.withDriver = true,
    this.fuelIncluded = false,
    this.availability = MachineryAvailability.available,
    required this.badge,
    required this.description,
    this.specifications = const {},
  });

  bool get isAvailable => availability == MachineryAvailability.available;
  String get hourlyRateFormatted => '₹$hourlyRate';
  String get dailyRateFormatted => '₹$dailyRate';

  String get availabilityText {
    switch (availability) {
      case MachineryAvailability.available:
        return 'Available Now';
      case MachineryAvailability.booked:
        return 'Booked Today';
      case MachineryAvailability.unavailable:
        return 'Unavailable';
    }
  }

  MachineryItem copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? category,
    String? hp,
    MachineryProvider? provider,
    String? location,
    double? distanceKm,
    int? hourlyRate,
    int? dailyRate,
    String? rentalUnit,
    String? implementsAttached,
    bool? withDriver,
    bool? fuelIncluded,
    MachineryAvailability? availability,
    String? badge,
    String? description,
    Map<String, String>? specifications,
  }) {
    return MachineryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      category: category ?? this.category,
      hp: hp ?? this.hp,
      provider: provider ?? this.provider,
      location: location ?? this.location,
      distanceKm: distanceKm ?? this.distanceKm,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dailyRate: dailyRate ?? this.dailyRate,
      rentalUnit: rentalUnit ?? this.rentalUnit,
      implementsAttached: implementsAttached ?? this.implementsAttached,
      withDriver: withDriver ?? this.withDriver,
      fuelIncluded: fuelIncluded ?? this.fuelIncluded,
      availability: availability ?? this.availability,
      badge: badge ?? this.badge,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
    );
  }
}

class MachineryBooking {
  final String id;
  final String machineryId;
  final String machineryName;
  final String brand;
  final String category;
  final String hp;
  final String ownerName;
  final String ownerPhone;
  final String farmerName;
  final String farmerPhone;
  final DateTime bookingDate;
  final String startTime;
  final int durationHours;
  final String implementAttached;
  final bool needDriver;
  final String deliveryPlot;
  final int hourlyRate;
  final int totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final String? cancellationReason;

  const MachineryBooking({
    required this.id,
    required this.machineryId,
    required this.machineryName,
    required this.brand,
    required this.category,
    required this.hp,
    required this.ownerName,
    required this.ownerPhone,
    required this.farmerName,
    required this.farmerPhone,
    required this.bookingDate,
    required this.startTime,
    required this.durationHours,
    required this.implementAttached,
    required this.needDriver,
    required this.deliveryPlot,
    required this.hourlyRate,
    required this.totalAmount,
    this.status = BookingStatus.confirmed,
    required this.createdAt,
    this.cancellationReason,
  });

  String get statusDisplay {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  MachineryBooking copyWith({
    String? id,
    String? machineryId,
    String? machineryName,
    String? brand,
    String? category,
    String? hp,
    String? ownerName,
    String? ownerPhone,
    String? farmerName,
    String? farmerPhone,
    DateTime? bookingDate,
    String? startTime,
    int? durationHours,
    String? implementAttached,
    bool? needDriver,
    String? deliveryPlot,
    int? hourlyRate,
    int? totalAmount,
    BookingStatus? status,
    DateTime? createdAt,
    String? cancellationReason,
  }) {
    return MachineryBooking(
      id: id ?? this.id,
      machineryId: machineryId ?? this.machineryId,
      machineryName: machineryName ?? this.machineryName,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      hp: hp ?? this.hp,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      durationHours: durationHours ?? this.durationHours,
      implementAttached: implementAttached ?? this.implementAttached,
      needDriver: needDriver ?? this.needDriver,
      deliveryPlot: deliveryPlot ?? this.deliveryPlot,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
