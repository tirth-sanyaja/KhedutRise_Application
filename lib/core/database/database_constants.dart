/// Constants for KhedutRise Local & Remote Database Collections
class DatabaseCollections {
  const DatabaseCollections._();

  static const String users = 'users';
  static const String farms = 'farms';
  static const String diseaseScans = 'disease_scans';
  static const String cropRecommendations = 'crop_recommendations';
  static const String chats = 'chats';
  static const String expenses = 'expenses';
  static const String bookings = 'bookings';

  static const List<String> all = [
    users,
    farms,
    diseaseScans,
    cropRecommendations,
    chats,
    expenses,
    bookings,
  ];
}
