/// Centralized image and icon asset paths for KhedutRise (no duplicates).
class AppImages {
  AppImages._();

  static const String _imgDir = 'resources/images';
  static const String _iconDir = 'resources/icons';

  // Brand & Landscapes
  static const String appLogo = '$_imgDir/app_logo.png';
  static const String hillsLandscape = '$_imgDir/hills_landscape.png';
  static const String landCover = '$_imgDir/land_cover.png';

  // Crops & Leaf Diagnosis Samples
  static const String cottonCrop = '$_imgDir/cotton_crop.png';
  static const String groundnutCrop = '$_imgDir/groundnut_crop.png';
  static const String wheatCrop = '$_imgDir/wheat_crop.png';
  static const String cuminCrop = '$_imgDir/cumin_crop.png';
  static const String healthyLeafSample = '$_imgDir/healthy_leaf_sample.png';
  static const String diseasedLeafSample = '$_imgDir/diseased_leaf_sample.png';

  // Farm Machinery & Rentals
  static const String tractorMahindra = '$_imgDir/tractor_mahindra.png';
  static const String droneSprayer = '$_imgDir/drone_sprayer.png';
  static const String combineHarvester = '$_imgDir/combine_harvester.png';

  // Feature Icons
  static const String tractorIcon = '$_iconDir/tractor_icon.jpeg';
  static const String cropSproutIcon = '$_iconDir/crop_sprout_icon.jpeg';
  static const String aiBotIcon = '$_iconDir/ai_bot_icon.jpeg';
  static const String farmHouseIcon = '$_iconDir/farm_house_icon.jpeg';
  static const String profileIcon = '$_iconDir/profile_icon.jpeg';
  static const String searchIcon = '$_iconDir/search_icon.jpeg';
  static const String addIcon = '$_iconDir/add_icon.jpeg';
  static const String verifiedBadge = '$_iconDir/verified_badge.png';

  /// Gallery sample photos used in SelectPhotoScreen for leaf scanning.
  static const List<String> leafScanGallerySamples = [
    cottonCrop,
    groundnutCrop,
    healthyLeafSample,
    diseasedLeafSample,
    wheatCrop,
    cuminCrop,
  ];
}
