import 'dart:convert';
import 'package:flutter/services.dart';

/// Paths and helper loaders for JSON data & translations inside `resources/`.
class AppDataResources {
  AppDataResources._();

  static const String cropsCatalogJson = 'resources/data/crops_catalog.json';
  static const String apmcMandiRatesJson =
      'resources/data/apmc_mandi_rates.json';
  static const String govtSchemesJson = 'resources/data/govt_schemes.json';

  static const String translationsEnJson = 'resources/translations/en.json';
  static const String translationsGuJson = 'resources/translations/gu.json';

  /// Loads and decodes a JSON resource file from bundle.
  static Future<Map<String, dynamic>> loadJsonMap(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
