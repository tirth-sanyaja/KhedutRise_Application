import 'package:flutter/foundation.dart';
import '../models/machinery_model.dart';

class MachineryService extends ChangeNotifier {
  MachineryService._internal() {
    _loadInitialMachinery();
    _loadInitialBookings();
  }

  static final MachineryService instance = MachineryService._internal();

  final List<MachineryItem> _machineries = [];
  final List<MachineryBooking> _bookings = [];

  List<MachineryItem> get machineries => List.unmodifiable(_machineries);
  List<MachineryBooking> get bookings => List.unmodifiable(_bookings);

  List<MachineryBooking> get upcomingBookings =>
      _bookings.where((b) => b.status == BookingStatus.confirmed).toList();

  List<MachineryBooking> get activeBookings =>
      _bookings.where((b) => b.status == BookingStatus.active).toList();

  List<MachineryBooking> get completedBookings =>
      _bookings.where((b) => b.status == BookingStatus.completed).toList();

  List<MachineryBooking> get cancelledBookings =>
      _bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  MachineryItem? getMachineryById(String id) {
    try {
      return _machineries.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Converts a time string like "08:00 AM" or "02:30 PM" to fractional hours (e.g. 14.5)
  double _timeStringToHours(String timeStr) {
    final clean = timeStr.trim().toUpperCase();
    final isPm = clean.contains('PM');
    final isAm = clean.contains('AM');
    final parts = clean
        .replaceAll('AM', '')
        .replaceAll('PM', '')
        .trim()
        .split(':');
    int hour = int.tryParse(parts[0]) ?? 8;
    int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;

    return hour + (minute / 60.0);
  }

  /// Checks if another confirmed or active booking overlaps with the requested date and time slot
  bool hasConflict(
    String machineryId,
    DateTime requestedDate,
    String startTime,
    int durationHours, {
    String? excludeBookingId,
  }) {
    final reqStart = _timeStringToHours(startTime);
    final reqEnd = reqStart + durationHours;

    for (final booking in _bookings) {
      if (booking.machineryId != machineryId) continue;
      if (excludeBookingId != null && booking.id == excludeBookingId) continue;
      if (booking.status == BookingStatus.cancelled ||
          booking.status == BookingStatus.completed) {
        continue;
      }

      // Check date equality (year, month, day)
      final sameDate =
          booking.bookingDate.year == requestedDate.year &&
          booking.bookingDate.month == requestedDate.month &&
          booking.bookingDate.day == requestedDate.day;

      if (sameDate) {
        final bStart = _timeStringToHours(booking.startTime);
        final bEnd = bStart + booking.durationHours;

        // Interval overlap: max(startA, startB) < min(endA, endB)
        final overlapStart = reqStart > bStart ? reqStart : bStart;
        final overlapEnd = reqEnd < bEnd ? reqEnd : bEnd;

        if (overlapStart < overlapEnd) {
          return true;
        }
      }
    }
    return false;
  }

  /// Creates a new booking and saves locally
  MachineryBooking createBooking({
    required MachineryItem machinery,
    required String farmerName,
    required String farmerPhone,
    required DateTime bookingDate,
    required String startTime,
    required int durationHours,
    required String implementAttached,
    required bool needDriver,
    required String deliveryPlot,
    required int hourlyRate,
    required int totalAmount,
  }) {
    final bookingId = 'TR-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final newBooking = MachineryBooking(
      id: bookingId,
      machineryId: machinery.id,
      machineryName: machinery.name,
      brand: machinery.brand,
      category: machinery.category,
      hp: machinery.hp,
      ownerName: machinery.provider.name,
      ownerPhone: machinery.provider.phone,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      bookingDate: bookingDate,
      startTime: startTime,
      durationHours: durationHours,
      implementAttached: implementAttached,
      needDriver: needDriver,
      deliveryPlot: deliveryPlot,
      hourlyRate: hourlyRate,
      totalAmount: totalAmount,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
    );

    _bookings.insert(0, newBooking);
    notifyListeners();
    return newBooking;
  }

  /// Cancels an existing booking
  bool cancelBooking(String bookingId, {String? reason}) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index >= 0) {
      final old = _bookings[index];
      _bookings[index] = old.copyWith(
        status: BookingStatus.cancelled,
        cancellationReason: reason ?? 'Cancelled by farmer',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void _loadInitialMachinery() {
    _machineries.addAll([
      const MachineryItem(
        id: 'TR-101',
        name: 'Mahindra 575 DI XP Plus',
        brand: 'Mahindra',
        model: '575 DI XP Plus',
        category: 'Tractor',
        hp: '47 HP',
        provider: MachineryProvider(
          id: 'PR-01',
          name: 'Ramesh Patel',
          phone: '+91 98250 12345',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 54,
        ),
        location: 'Sardhar, Rajkot (2.5 km)',
        distanceKm: 2.5,
        hourlyRate: 650,
        dailyRate: 3600,
        implementsAttached: 'Rotavator 6ft, 9-Tyne Cultivator',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Top Rated',
        description:
            'Reliable 47 HP tractor ideal for all farm operations including deep ploughing, tilling, and transport across Saurashtra black cotton soil.',
        specifications: {
          'Engine Power': '47 HP @ 2000 RPM',
          'Cylinders': '4 Cylinders, 2979 cc',
          'Transmission': '8 Forward + 2 Reverse',
          'Lifting Capacity': '1500 kg Hydraulic',
          'Fuel Tank': '47 Litres',
          'Brakes': 'Oil Immersed Brakes',
        },
      ),
      const MachineryItem(
        id: 'TR-102',
        name: 'John Deere 5050 D 4WD',
        brand: 'John Deere',
        model: '5050 D 4WD',
        category: 'Tractor',
        hp: '50 HP',
        provider: MachineryProvider(
          id: 'PR-02',
          name: 'Hitesh Ahir',
          phone: '+91 97241 87654',
          village: 'Kuvadva Road',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 72,
        ),
        location: 'Kuvadva Road (4.1 km)',
        distanceKm: 4.1,
        hourlyRate: 750,
        dailyRate: 4200,
        implementsAttached: 'MB Plough, Disc Harrow',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Heavy Duty',
        description:
            'High-torque 4WD machine built for heavy tillage and laser leveling. Experienced driver provided for maximum productivity.',
        specifications: {
          'Engine Power': '50 HP @ 2100 RPM',
          'Cylinders': '3 Cylinders Turbocharged',
          'Transmission': 'Collarshift 8F + 4R',
          'Lifting Capacity': '1600 kg',
          'Drive': '4 Wheel Drive (4WD)',
          'Power Steering': 'Hydrostatic',
        },
      ),
      const MachineryItem(
        id: 'TR-103',
        name: 'Kubota Neostar B2741S (4WD)',
        brand: 'Kubota',
        model: 'Neostar B2741S',
        category: 'Tractor',
        hp: '27 HP',
        provider: MachineryProvider(
          id: 'PR-03',
          name: 'Bharatbhai Dabhi',
          phone: '+91 94282 34567',
          village: 'Gondal Highway',
          district: 'Rajkot',
          rating: 4.7,
          totalBookings: 38,
        ),
        location: 'Gondal Highway (5.0 km)',
        distanceKm: 5.0,
        hourlyRate: 450,
        dailyRate: 2600,
        implementsAttached: 'Orchard Sprayer, Intercultivator',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Best for Orchards',
        description:
            'Compact, highly agile mini tractor engineered for inter-cultivation in cotton, groundnut, and orchard spraying.',
        specifications: {
          'Engine Power': '27 HP E-TVCS',
          'Cylinders': '3 Cylinders',
          'Turning Radius': '2.1 m (Ultra Narrow)',
          'PTO': 'Dual Speed PTO',
          'Fuel Efficiency': 'High (Diesel included)',
        },
      ),
      const MachineryItem(
        id: 'TR-104',
        name: 'Swaraj 744 FE',
        brand: 'Swaraj',
        model: '744 FE',
        category: 'Tractor',
        hp: '48 HP',
        provider: MachineryProvider(
          id: 'PR-04',
          name: 'Jayesh Khunt',
          phone: '+91 99099 56789',
          village: 'Kotda Sangani',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 61,
        ),
        location: 'Kotda Sangani (3.2 km)',
        distanceKm: 3.2,
        hourlyRate: 620,
        dailyRate: 3400,
        implementsAttached: 'Heavy Hydraulic Trolley (5 Ton)',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.booked,
        badge: 'Haulage Specialist',
        description:
            'Rugged 48 HP Swaraj tractor equipped with 5-ton hydraulic tipping trolley for crop transport and field clearance.',
        specifications: {
          'Engine Power': '48 HP @ 2000 RPM',
          'Cylinders': '3 Cylinders, 3136 cc',
          'Clutch': 'Dual Clutch',
          'Trolley Capacity': '5 Metric Tonnes',
        },
      ),
      const MachineryItem(
        id: 'TR-105',
        name: 'Claas Crop Tiger 30 Harvester',
        brand: 'Claas',
        model: 'Crop Tiger 30',
        category: 'Harvester',
        hp: '60 HP',
        provider: MachineryProvider(
          id: 'PR-05',
          name: 'Kisan Agro Equipment',
          phone: '+91 98980 43210',
          village: 'Rajkot Rural',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 93,
        ),
        location: 'Rajkot Rural (7.8 km)',
        distanceKm: 7.8,
        hourlyRate: 1800,
        dailyRate: 14000,
        rentalUnit: 'per acre',
        implementsAttached: 'Wheat, Soybean & Paddy Cutter Bar',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Fast Harvesting',
        description:
            'State-of-the-art combine harvester for rapid harvesting and grain separation. Negligible grain loss and clean straw output.',
        specifications: {
          'Cutter Bar Width': '7 Feet Multicrop',
          'Grain Tank': '1200 Litres',
          'Field Capacity': '1.5 Acres / Hour',
          'Crops Supported': 'Wheat, Soybean, Gram, Mustard',
        },
      ),
      const MachineryItem(
        id: 'TR-106',
        name: 'Automatic Laser Land Leveler',
        brand: 'AgroTech',
        model: 'Laser Leveller Pro',
        category: 'Other Farm Machinery',
        hp: 'Laser Guided',
        provider: MachineryProvider(
          id: 'PR-06',
          name: 'Sardhar Agro Tools',
          phone: '+91 98790 99887',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.7,
          totalBookings: 27,
        ),
        location: 'Sardhar Main Market (1.8 km)',
        distanceKm: 1.8,
        hourlyRate: 550,
        dailyRate: 3000,
        implementsAttached: 'Transmitter + Receiver Mast',
        withDriver: false,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Water Saver',
        description:
            'Precision laser leveling scraper that eliminates field undulations, reducing irrigation water requirements by up to 30%.',
        specifications: {
          'Laser Range': '800 m Diameter',
          'Accuracy': '±1 mm per 10 m',
          'Blade Width': '7 Feet Heavy Steel',
          'Control Box': 'Digital Automatic',
        },
      ),
      const MachineryItem(
        id: 'TR-107',
        name: 'Sonalika Tiger DI 55 CRDS 4WD',
        brand: 'Sonalika',
        model: 'Tiger DI 55 CRDS 4WD',
        category: 'Tractor',
        hp: '55 HP',
        provider: MachineryProvider(
          id: 'PR-07',
          name: 'Manish Vaghani',
          phone: '+91 97123 45678',
          village: 'Sardhar Bypass',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 46,
        ),
        location: 'Sardhar Bypass (1.2 km)',
        distanceKm: 1.2,
        hourlyRate: 700,
        dailyRate: 3900,
        implementsAttached: '11-Tyne Super Seeder, 7ft Shaktiman Rotavator',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'High Fuel Efficiency',
        description:
            'Modern CRDS technology tractor delivering outstanding power and low fuel burn for Saurashtra farmers.',
        specifications: {
          'Engine Power': '55 HP Common Rail',
          'Drive': '4WD Dual Traction',
          'Lift Capacity': '2000 kg Heavy Lift',
          'Hydraulics': 'Precision Automatic Draft Control',
        },
      ),
      const MachineryItem(
        id: 'TR-108',
        name: 'New Holland 3630 TX Special Edition',
        brand: 'New Holland',
        model: '3630 TX Super',
        category: 'Tractor',
        hp: '55 HP',
        provider: MachineryProvider(
          id: 'PR-08',
          name: 'Pravin Patel',
          phone: '+91 98242 77112',
          village: 'Shapar',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 59,
        ),
        location: 'Gondal Road, Shapar (3.8 km)',
        distanceKm: 3.8,
        hourlyRate: 720,
        dailyRate: 4000,
        implementsAttached: 'Reversible Hydraulic MB Plough, Heavy Disc Ridger',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Deep Ploughing Pro',
        description:
            'Proven workhorse for tough deep-furrow ploughing. Comes with reversible hydraulic MB plough and experienced driver.',
        specifications: {
          'Engine Power': '55 HP FPT Engine',
          'Transmission': 'Double Clutch Synchronized',
          'Hydraulic Output': 'High Flow Dual Remote',
        },
      ),
      const MachineryItem(
        id: 'TR-109',
        name: 'Captain 280 DI 4WD Mini Tractor',
        brand: 'Captain',
        model: '280 DI 4WD',
        category: 'Tractor',
        hp: '28 HP',
        provider: MachineryProvider(
          id: 'PR-09',
          name: 'Dineshbhai Makwana',
          phone: '+91 94277 88990',
          village: 'Kuvadva',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 42,
        ),
        location: 'Kuvadva GIDC (4.5 km)',
        distanceKm: 4.5,
        hourlyRate: 420,
        dailyRate: 2400,
        implementsAttached: 'Rotary Tiller, Cotton Inter-row Weeder',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Narrow Track Specialist',
        description:
            'Specially built for Saurashtra cotton & groundnut farmers for inter-row weeding without damaging root structures.',
        specifications: {
          'Engine Power': '28 HP 4WD',
          'Track Width': 'Adjustable 3-4 Feet',
          'Fuel Type': 'Ultra Fuel Efficient Diesel',
        },
      ),
      const MachineryItem(
        id: 'TR-110',
        name: 'Eicher 485 Super DI',
        brand: 'Eicher',
        model: '485 Super DI',
        category: 'Tractor',
        hp: '45 HP',
        provider: MachineryProvider(
          id: 'PR-10',
          name: 'Ghanshyambhai Radadiya',
          phone: '+91 99798 12340',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.7,
          totalBookings: 68,
        ),
        location: 'Atkot Road, Sardhar (2.0 km)',
        distanceKm: 2.0,
        hourlyRate: 580,
        dailyRate: 3200,
        implementsAttached: 'Zero Till Multi-Crop Seed Drill, 2-Row Planter',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Budget Friendly',
        description:
            'Reliable air-cooled workhorse for seed sowing and tilling with very economical rental rates.',
        specifications: {
          'Engine Power': '45 HP Air-Cooled',
          'Cylinders': '3 Cylinders, 2945 cc',
          'Fuel Efficiency': 'Highest in class',
        },
      ),
      const MachineryItem(
        id: 'TR-111',
        name: 'Shaktiman Semi Champion 7ft Rotavator',
        brand: 'Shaktiman',
        model: 'Semi Champion 7ft',
        category: 'Rotavator',
        hp: '40-55 HP Req.',
        provider: MachineryProvider(
          id: 'PR-11',
          name: 'Jayesh Khunt',
          phone: '+91 99099 56789',
          village: 'Kotda Sangani',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 81,
        ),
        location: 'Kotda Sangani (3.2 km)',
        distanceKm: 3.2,
        hourlyRate: 350,
        dailyRate: 2000,
        implementsAttached: 'L-Blade Rotor, Heavy Duty Multi-Speed Gearbox',
        withDriver: false,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Top Rotavator',
        description:
            'Heavy duty 7-foot rotavator with boron steel L-blades for creating super fine seedbeds in a single pass.',
        specifications: {
          'Tilling Width': '7 Feet (2.1 meters)',
          'Number of Blades': '48 L-Type Boron Steel',
          'Gearbox': 'Multi-speed with oil bath lubrication',
          'Weight': '465 kg',
        },
      ),
      const MachineryItem(
        id: 'TR-112',
        name: '9-Tyne Heavy Rigid Cultivator',
        brand: 'Bharat Agro',
        model: 'Rigid 9-Tyne',
        category: 'Cultivator',
        hp: '35+ HP Req.',
        provider: MachineryProvider(
          id: 'PR-12',
          name: 'Ramesh Patel',
          phone: '+91 98250 12345',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 65,
        ),
        location: 'Sardhar (2.5 km)',
        distanceKm: 2.5,
        hourlyRate: 280,
        dailyRate: 1500,
        implementsAttached: 'Forged Tynes, High Clearance Frame',
        withDriver: false,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Field Ready',
        description:
            'Heavy channel cultivator designed for deep primary soil aerating and weed clearing prior to monsoon sowing.',
        specifications: {
          'Tynes': '9 Heavy Forged Carbon Steel',
          'Frame': 'High tensile tubular frame',
          'Working Depth': 'Up to 9 inches',
        },
      ),
      const MachineryItem(
        id: 'TR-113',
        name: 'Dasmesh Automatic Seed Drill & Fertilizer',
        brand: 'Dasmesh',
        model: 'Auto Drill 9-Row',
        category: 'Seed Drill',
        hp: '45+ HP Req.',
        provider: MachineryProvider(
          id: 'PR-13',
          name: 'Ghanshyambhai Radadiya',
          phone: '+91 99798 12340',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 52,
        ),
        location: 'Atkot Road, Sardhar (2.0 km)',
        distanceKm: 2.0,
        hourlyRate: 400,
        dailyRate: 2200,
        implementsAttached: '9-Row Fluted Roller Mechanism',
        withDriver: false,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Precision Sowing',
        description:
            'Combined seed drill and fertilizer applicator ensuring uniform seed depth and fertilizer placement for maximum germination.',
        specifications: {
          'Rows': '9 Adjustable Rows',
          'Metering': 'Fluted roller seed & fertilizer mechanism',
          'Hopper Capacity': '75 kg Seed + 75 kg Fertilizer',
        },
      ),
      const MachineryItem(
        id: 'TR-114',
        name: 'Garuda Kisan Drone Sprayer 10L',
        brand: 'Garuda Aerospace',
        model: 'Kisan Drone 10L',
        category: 'Other Farm Machinery',
        hp: 'Electric Drone (10L)',
        provider: MachineryProvider(
          id: 'PR-14',
          name: 'Kishan Drone Services',
          phone: '+91 98255 11223',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 110,
        ),
        location: 'Sardhar Main (1.5 km)',
        distanceKm: 1.5,
        hourlyRate: 500,
        dailyRate: 3500,
        rentalUnit: 'per acre',
        implementsAttached:
            'High-Precision Micron Atomizers, Radar Terrain Sensing',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Drone Sprayer',
        description:
            'Certified Kisan drone sprayer. Sprays 1 acre in 6-8 minutes with 90% water saving and 30% chemical efficiency. Licensed pilot included.',
        specifications: {
          'Payload Tank': '10 Litres',
          'Spray Width': '4.5 - 6.0 Meters',
          'Flight Time': '15-20 Minutes per battery',
          'Coverage': '25-30 Acres / Day',
        },
      ),
      const MachineryItem(
        id: 'TR-115',
        name: 'IoTechWorld Agribot 16L Drone',
        brand: 'IoTechWorld',
        model: 'Agribot Pro 16L',
        category: 'Other Farm Machinery',
        hp: 'Heavy Hexacopter (16L)',
        provider: MachineryProvider(
          id: 'PR-15',
          name: 'AgriFly Saurashtra',
          phone: '+91 97129 88776',
          village: 'Kuvadva',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 88,
        ),
        location: 'Kuvadva Highway (4.0 km)',
        distanceKm: 4.0,
        hourlyRate: 650,
        dailyRate: 4200,
        rentalUnit: 'per acre',
        implementsAttached:
            'Dual Centrifugal Spray Nozzles, Obstacle Avoidance',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Heavy Drone',
        description:
            'High-payload 16L agricultural drone for ultra-dense crops like Cotton, Cumin, and Groundnut. Rapid coverage with dual battery set.',
        specifications: {
          'Payload Capacity': '16 Litres',
          'Nozzles': 'Centrifugal Atomizers',
          'Speed': '6 m/s Autonomous GPS flight',
        },
      ),
      const MachineryItem(
        id: 'TR-116',
        name: 'Preet 987 Multicrop Combine Harvester',
        brand: 'Preet',
        model: '987 Deluxe AC',
        category: 'Harvester',
        hp: '101 HP',
        provider: MachineryProvider(
          id: 'PR-16',
          name: 'Patel Harvester Hub',
          phone: '+91 98251 33445',
          village: 'Gondal',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 142,
        ),
        location: 'Gondal Bypass (6.5 km)',
        distanceKm: 6.5,
        hourlyRate: 2200,
        dailyRate: 18000,
        rentalUnit: 'per acre',
        implementsAttached: '14ft Multicrop Cutter, High-Speed Straw Chopper',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Heavy Combine',
        description:
            '101 HP heavy-duty combine harvester for fast harvesting of Wheat, Paddy, Soybean, and Gram with zero spillage.',
        specifications: {
          'Engine Power': '101 HP 6-Cylinder Turbo',
          'Cutter Bar Width': '14 Feet Heavy Duty',
          'Threshing Drum': 'Multi-speed rasp bar',
          'Grain Tank': '2400 Litres',
        },
      ),
      const MachineryItem(
        id: 'TR-117',
        name: 'Kartar 4000 Multicrop Harvester',
        brand: 'Kartar',
        model: '4000 Self Propelled',
        category: 'Harvester',
        hp: '76 HP',
        provider: MachineryProvider(
          id: 'PR-17',
          name: 'Sardar Agro Machinery',
          phone: '+91 94272 66554',
          village: 'Shapar',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 79,
        ),
        location: 'Shapar GIDC (3.9 km)',
        distanceKm: 3.9,
        hourlyRate: 1950,
        dailyRate: 15500,
        rentalUnit: 'per acre',
        implementsAttached: '10ft Floating Cutter Bar, 5 Straw Walkers',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Fast Harvester',
        description:
            'Popular 76 HP self-propelled harvester. Highly maneuverable in Saurashtra fields with clean grain output.',
        specifications: {
          'Engine Power': '76 HP @ 2200 RPM',
          'Cutter Width': '10.5 Feet',
          'Grain Loss': '< 1.5% Certified',
        },
      ),
      const MachineryItem(
        id: 'TR-118',
        name: 'Mahindra Oja 2118 4WD Mini Tractor',
        brand: 'Mahindra',
        model: 'Oja 2118 4WD',
        category: 'Tractor',
        hp: '18 HP',
        provider: MachineryProvider(
          id: 'PR-18',
          name: 'Tirth Agro Equipment',
          phone: '+91 99092 11002',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 35,
        ),
        location: 'Sardhar Village (1.1 km)',
        distanceKm: 1.1,
        hourlyRate: 380,
        dailyRate: 2100,
        implementsAttached: 'Orchard Sprayer, 2-Row Weeder, Mini Rotavator',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Smart Mini 4WD',
        description:
            'Latest generation Mahindra Oja 18 HP lightweight tractor for row crops like cotton, groundnut, and orchard inter-cultivation.',
        specifications: {
          'Engine Power': '18 HP 3-Cylinder',
          'Drive': '4WD All-Wheel Drive',
          'Transmission': '12 Forward + 12 Reverse Shuttle',
          'Turning Radius': '2.0 Meters Ultra Compact',
        },
      ),
      const MachineryItem(
        id: 'TR-119',
        name: 'Swaraj Code Narrow Mini Tractor',
        brand: 'Swaraj',
        model: 'Code 11.1 HP',
        category: 'Tractor',
        hp: '11.1 HP',
        provider: MachineryProvider(
          id: 'PR-19',
          name: 'Bhaveshbhai Korat',
          phone: '+91 98254 99001',
          village: 'Sardhar Bypass',
          district: 'Rajkot',
          rating: 4.7,
          totalBookings: 29,
        ),
        location: 'Sardhar Bypass (1.6 km)',
        distanceKm: 1.6,
        hourlyRate: 320,
        dailyRate: 1800,
        implementsAttached: 'Adjustable Inter-row Rotary Weeder, Ridger',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Ultra Narrow 2.5ft',
        description:
            'Single-seat narrow gauge tractor designed specifically for weeding between cotton, groundnut, and vegetable ridges.',
        specifications: {
          'Engine Power': '11.1 HP Petrol-Hybrid',
          'Track Width': '2.5 Feet Narrow Track',
          'Turning Radius': '1.8 Meters',
        },
      ),
      const MachineryItem(
        id: 'TR-120',
        name: 'VST Shakti MT 180D JAI 4WD',
        brand: 'VST Shakti',
        model: 'MT 180D JAI',
        category: 'Tractor',
        hp: '18 HP',
        provider: MachineryProvider(
          id: 'PR-20',
          name: 'Kishanbhai Vora',
          phone: '+91 94280 44556',
          village: 'Kotda Sangani',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 47,
        ),
        location: 'Kotda Sangani (3.5 km)',
        distanceKm: 3.5,
        hourlyRate: 360,
        dailyRate: 2000,
        implementsAttached: 'Mini Rotavator 3ft, Bed Former',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'High Fuel Economy',
        description:
            'Reliable 18 HP 4WD compact tractor built for high efficiency tillage in orchards and close-planted row crops.',
        specifications: {
          'Engine Power': '18.5 HP 3-Cylinder Diesel',
          'Drive': '4WD with Differential Lock',
          'PTO': 'Dual Speed 540 & 1000 RPM',
        },
      ),
      const MachineryItem(
        id: 'TR-121',
        name: 'John Deere 5310 GearPro 4WD',
        brand: 'John Deere',
        model: '5310 GearPro',
        category: 'Tractor',
        hp: '55 HP',
        provider: MachineryProvider(
          id: 'PR-21',
          name: 'Vikramsinh Jadeja',
          phone: '+91 98252 88990',
          village: 'Kuvadva Road',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 85,
        ),
        location: 'Kuvadva Road (4.3 km)',
        distanceKm: 4.3,
        hourlyRate: 780,
        dailyRate: 4500,
        implementsAttached:
            'Laser Land Leveler, Heavy Subsoiler, 8ft Rotavator',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Heavy Workhorse',
        description:
            'Heavy-duty 55 HP tractor with Trem-IV engine for demanding laser leveling, deep ploughing, and big baler operations.',
        specifications: {
          'Engine Power': '55 HP Turbocharged Intercooled',
          'Transmission': '12 Forward + 4 Reverse GearPro',
          'Lifting Capacity': '2000 kg Heavy Hydraulic',
        },
      ),
      const MachineryItem(
        id: 'TR-122',
        name: 'Powertrac Euro 60 Next High Torque',
        brand: 'Powertrac',
        model: 'Euro 60 Next',
        category: 'Tractor',
        hp: '60 HP',
        provider: MachineryProvider(
          id: 'PR-22',
          name: 'Ashokbhai Patel',
          phone: '+91 99790 33441',
          village: 'Gondal Road',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 63,
        ),
        location: 'Gondal Road (5.5 km)',
        distanceKm: 5.5,
        hourlyRate: 800,
        dailyRate: 4600,
        implementsAttached: 'Reversible MB Plough 3-Bottom, Heavy Disc Ridger',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: '60 HP High Torque',
        description:
            'Super powerful 60 HP tractor for deep breaking of hard black soil pan and fast land reclaiming.',
        specifications: {
          'Engine Power': '60 HP 4-Cylinder 3680 cc',
          'Lift Capacity': '2000 kg Balanced Hydraulic',
          'Clutch': 'Double Clutch with Ind. PTO',
        },
      ),
      const MachineryItem(
        id: 'TR-123',
        name: 'Swaraj 855 FE 4WD Iconic',
        brand: 'Swaraj',
        model: '855 FE 4WD',
        category: 'Tractor',
        hp: '52 HP',
        provider: MachineryProvider(
          id: 'PR-23',
          name: 'Mukeshbhai Dholariya',
          phone: '+91 98248 77661',
          village: 'Sardhar Rural',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 91,
        ),
        location: 'Sardhar Rural (2.2 km)',
        distanceKm: 2.2,
        hourlyRate: 700,
        dailyRate: 3900,
        implementsAttached: '11-Tyne Cultivator, 7ft Shaktiman Rotavator',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'All-Terrain Legend',
        description:
            'The iconic 52 HP Swaraj tractor favored by Saurashtra farmers for heavy traction, durability, and reliability.',
        specifications: {
          'Engine Power': '52 HP 3-Cylinder 3478 cc',
          'Transmission': 'Multi-speed Reverse PTO',
          'Drive': '4WD Dual Traction',
        },
      ),
      const MachineryItem(
        id: 'TR-124',
        name: 'Shaktiman Square Straw Baler',
        brand: 'Shaktiman',
        model: 'Square Baler Pro',
        category: 'Other Farm Machinery',
        hp: '45+ HP Req.',
        provider: MachineryProvider(
          id: 'PR-24',
          name: 'Green Agro Baling',
          phone: '+91 97140 22334',
          village: 'Rajkot Rural',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 74,
        ),
        location: 'Rajkot Rural (5.2 km)',
        distanceKm: 5.2,
        hourlyRate: 600,
        dailyRate: 3500,
        rentalUnit: 'per acre',
        implementsAttached: 'Automatic Heavy Twine Knotter, Chute Extension',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Baler / Fodder',
        description:
            'High-speed straw baler that compresses groundnut, wheat, and cotton residues into compact rectangular bales for easy cattle feed transport.',
        specifications: {
          'Bale Dimensions': '14 x 18 inches, length adjustable',
          'Field Capacity': '1.5 - 2.0 Acres / Hour',
          'Knotter': 'Heavy German Knotting mechanism',
        },
      ),
      const MachineryItem(
        id: 'TR-125',
        name: 'JCB 3DX Plus Backhoe Loader',
        brand: 'JCB',
        model: '3DX Plus',
        category: 'Other Farm Machinery',
        hp: '74 HP Turbo',
        provider: MachineryProvider(
          id: 'PR-25',
          name: 'Saurashtra Earthmovers',
          phone: '+91 98250 55443',
          village: 'Shapar Highway',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 128,
        ),
        location: 'Shapar Highway (3.4 km)',
        distanceKm: 3.4,
        hourlyRate: 1200,
        dailyRate: 9500,
        implementsAttached: '6-in-1 Front Shovel + Heavy Ditching Bucket',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Loader & Digger',
        description:
            'Indispensable for agricultural field boundary clearance, deepening farm ponds (Khet Talavadi), trenching water lines, and manure loading.',
        specifications: {
          'Engine Power': '74 HP CRDI Turbocharged',
          'Dig Depth': '4.77 Meters',
          'Loader Bucket': '1.0 cu.m Capacity',
        },
      ),
      const MachineryItem(
        id: 'TR-126',
        name: 'Mitra Bullet 600L Orchard Tractor Sprayer',
        brand: 'Mitra',
        model: 'Bullet 600L',
        category: 'Other Farm Machinery',
        hp: '40+ HP PTO Req.',
        provider: MachineryProvider(
          id: 'PR-26',
          name: 'Kisan Sprayers Sardhar',
          phone: '+91 94290 88771',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 43,
        ),
        location: 'Sardhar (2.0 km)',
        distanceKm: 2.0,
        hourlyRate: 450,
        dailyRate: 2500,
        implementsAttached:
            'Rear Axial Fan Blower, Brass Ceramic Double Nozzles',
        withDriver: false,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Boom / Orchard Sprayer',
        description:
            'Tractor PTO driven high-pressure mist sprayer. 600L chemical tank delivers ultra-dense coverage for cotton, orchards, and spices.',
        specifications: {
          'Tank Capacity': '600 Litres UV Stabilized',
          'Fan Diameter': '600 mm Heavy Aluminum',
          'Working Pressure': '40 Bar (Triple Piston Pump)',
        },
      ),
      const MachineryItem(
        id: 'TR-127',
        name: 'VST Shakti 130 DI Power Tiller',
        brand: 'VST Shakti',
        model: '130 DI',
        category: 'Other Farm Machinery',
        hp: '13 HP Diesel',
        provider: MachineryProvider(
          id: 'PR-27',
          name: 'Naranbhai Patel',
          phone: '+91 98792 11440',
          village: 'Sardhar Bypass',
          district: 'Rajkot',
          rating: 4.7,
          totalBookings: 38,
        ),
        location: 'Sardhar Bypass (1.8 km)',
        distanceKm: 1.8,
        hourlyRate: 280,
        dailyRate: 1500,
        implementsAttached:
            'Rotary Tillage Blades, Tail Wheel, Iron Cage Wheels',
        withDriver: true,
        fuelIncluded: true,
        availability: MachineryAvailability.available,
        badge: 'Power Tiller',
        description:
            'Multipurpose 13 HP walk-behind power tiller for small farm plots, wet land puddling, vegetable beds, and nursery preparation.',
        specifications: {
          'Engine Power': '13 HP Water Cooled',
          'Tilling Width': '600 mm',
          'Fuel Efficiency': 'High (Diesel)',
        },
      ),
      const MachineryItem(
        id: 'TR-128',
        name: 'Honda F300 Rotary Power Weeder',
        brand: 'Honda',
        model: 'F300 Mini',
        category: 'Other Farm Machinery',
        hp: '4.5 HP Petrol',
        provider: MachineryProvider(
          id: 'PR-28',
          name: 'Rajkot Agro Rentals',
          phone: '+91 99244 55660',
          village: 'Rajkot',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 51,
        ),
        location: 'Kuvadva Road (3.8 km)',
        distanceKm: 3.8,
        hourlyRate: 200,
        dailyRate: 1100,
        implementsAttached: 'Curved Weeding Blades, Depth Skid',
        withDriver: false,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Power Weeder',
        description:
            'Ultra lightweight 4.5 HP petrol power weeder that easily fits between narrow rows to clear weeds without soil compaction.',
        specifications: {
          'Engine Power': '4.5 HP 4-Stroke OHV Honda',
          'Weight': '38 kg (Ultra Light)',
          'Tilling Width': '450 mm',
        },
      ),
      const MachineryItem(
        id: 'TR-129',
        name: 'Shaktiman Super Seeder 7ft',
        brand: 'Shaktiman',
        model: 'Super Seeder Pro',
        category: 'Seed Drill',
        hp: '50+ HP Req.',
        provider: MachineryProvider(
          id: 'PR-29',
          name: 'Kishan Seeder Hire',
          phone: '+91 98253 66778',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 67,
        ),
        location: 'Sardhar Village (1.9 km)',
        distanceKm: 1.9,
        hourlyRate: 500,
        dailyRate: 2800,
        implementsAttached:
            'Rotary Stubble Mulcher + Precision Seed & Fertilizer Box',
        withDriver: false,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Super Seeder',
        description:
            'Revolutionary all-in-one machine that mulches standing crop residue, tills soil, and sows seeds with fertilizer in a single run.',
        specifications: {
          'Working Width': '7 Feet (2.1 meters)',
          'Rows': '11 Precision Tynes',
          'Hopper Capacity': '90 kg Seed + 90 kg Fertilizer',
        },
      ),
      const MachineryItem(
        id: 'TR-130',
        name: 'Punni Multi-Crop Auto Thresher',
        brand: 'Punni',
        model: 'Auto Clean 50',
        category: 'Other Farm Machinery',
        hp: '35+ HP Req.',
        provider: MachineryProvider(
          id: 'PR-30',
          name: 'Amrutbhai Vaghani',
          phone: '+91 94266 33221',
          village: 'Kotda Sangani',
          district: 'Rajkot',
          rating: 4.8,
          totalBookings: 45,
        ),
        location: 'Kotda Sangani (3.1 km)',
        distanceKm: 3.1,
        hourlyRate: 450,
        dailyRate: 2600,
        implementsAttached: 'Double High-Pressure Blower, Triple Sieve System',
        withDriver: true,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Crop Thresher',
        description:
            'Tractor PTO driven multi-crop thresher for Groundnut, Wheat, Cumin (Jeeru), Mustard, and Pulses with crystal clean grain output.',
        specifications: {
          'Capacity': '1500 - 2000 kg / Hour',
          'Blower': 'Double suction centrifugal blower',
          'Crops Handled': 'Wheat, Groundnut, Cumin, Gram, Mustard',
        },
      ),
      const MachineryItem(
        id: 'TR-131',
        name: 'Maschio Gaspardo 7ft Heavy Rotavator',
        brand: 'Maschio Gaspardo',
        model: 'Virat Pro 7ft',
        category: 'Rotavator',
        hp: '45-60 HP Req.',
        provider: MachineryProvider(
          id: 'PR-31',
          name: 'Gondal Agro Spares',
          phone: '+91 98240 77889',
          village: 'Gondal',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 71,
        ),
        location: 'Gondal Road (5.8 km)',
        distanceKm: 5.8,
        hourlyRate: 380,
        dailyRate: 2100,
        implementsAttached:
            'Heavy Multi-Speed Gearbox, 48 Boron Steel L-Blades',
        withDriver: false,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Premium Rotavator',
        description:
            'Italian engineered heavy duty rotavator delivering supreme seedbed pulverization for Saurashtra black soil.',
        specifications: {
          'Tilling Width': '7 Feet (2.1 meters)',
          'Blades': '48 Premium Boron Steel',
          'Weight': '480 kg Heavy Chassis',
        },
      ),
      const MachineryItem(
        id: 'TR-132',
        name: 'Lemken Opal 090 Hydraulic Reversible MB Plough',
        brand: 'Lemken',
        model: 'Opal 090 2-Bottom',
        category: 'Cultivator',
        hp: '50+ HP Req.',
        provider: MachineryProvider(
          id: 'PR-32',
          name: 'Sardhar Farm Implements',
          phone: '+91 97120 44550',
          village: 'Sardhar',
          district: 'Rajkot',
          rating: 4.9,
          totalBookings: 58,
        ),
        location: 'Sardhar Bypass (1.4 km)',
        distanceKm: 1.4,
        hourlyRate: 420,
        dailyRate: 2400,
        implementsAttached:
            'Double Acting Hydraulic Turnover, Boron Steel Points',
        withDriver: false,
        fuelIncluded: false,
        availability: MachineryAvailability.available,
        badge: 'Reversible MB Plough',
        description:
            'Top-grade 2-bottom reversible mouldboard plough for complete soil inversion and deep breaking of hardpans.',
        specifications: {
          'Bottoms': '2 Bottom Reversible',
          'Working Depth': 'Up to 14 Inches',
          'Steel': 'German Boron Treated',
        },
      ),
    ]);
  }

  void _loadInitialBookings() {
    final now = DateTime.now();
    _bookings.addAll([
      MachineryBooking(
        id: 'TR-8491',
        machineryId: 'TR-102',
        machineryName: 'John Deere 5050 D 4WD',
        brand: 'John Deere',
        category: 'Tractor',
        hp: '50 HP',
        ownerName: 'Hitesh Ahir',
        ownerPhone: '+91 97241 87654',
        farmerName: 'Tirthbhai Sanyaja',
        farmerPhone: '+91 98765 43210',
        bookingDate: now.add(const Duration(days: 1)),
        startTime: '02:00 PM',
        durationHours: 4,
        implementAttached: 'MB Plough',
        needDriver: true,
        deliveryPlot: 'Vishvas Plot A, Sardhar',
        hourlyRate: 750,
        totalAmount: 3000,
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      MachineryBooking(
        id: 'TR-8210',
        machineryId: 'TR-101',
        machineryName: 'Mahindra 575 DI XP Plus',
        brand: 'Mahindra',
        category: 'Tractor',
        hp: '47 HP',
        ownerName: 'Ramesh Patel',
        ownerPhone: '+91 98250 12345',
        farmerName: 'Tirthbhai Sanyaja',
        farmerPhone: '+91 98765 43210',
        bookingDate: now.subtract(const Duration(days: 3)),
        startTime: '08:00 AM',
        durationHours: 6,
        implementAttached: 'Rotavator 6ft',
        needDriver: true,
        deliveryPlot: 'Plot B (Cotton), Sardhar',
        hourlyRate: 650,
        totalAmount: 3900,
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      MachineryBooking(
        id: 'TR-7954',
        machineryId: 'TR-104',
        machineryName: 'Swaraj 744 FE',
        brand: 'Swaraj',
        category: 'Tractor',
        hp: '48 HP',
        ownerName: 'Jayesh Khunt',
        ownerPhone: '+91 99099 56789',
        farmerName: 'Tirthbhai Sanyaja',
        farmerPhone: '+91 98765 43210',
        bookingDate: now.subtract(const Duration(days: 7)),
        startTime: '10:00 AM',
        durationHours: 4,
        implementAttached: 'Heavy Hydraulic Trolley',
        needDriver: true,
        deliveryPlot: 'Vishvas Plot A, Sardhar',
        hourlyRate: 620,
        totalAmount: 2480,
        status: BookingStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 8)),
        cancellationReason: 'Postponed due to rainfall',
      ),
    ]);
  }
}
