import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';

class UserSettings {
  final String selectedSortOption;
  final CarFilter savedFilter;
  final bool notificationsEnabled;
  final bool qrScannerEnabled;
  final String themeMode;

  const UserSettings({
    this.selectedSortOption = 'price_low',
    this.savedFilter = const CarFilter(
      category: '',
      minPrice: 0.0,
      maxPrice: 1000.0,
      minYear: 2000,
      maxYear: 2025,
      fuelType: '',
      transmission: '',
      minSeats: 2,
    ),
    this.notificationsEnabled = true,
    this.qrScannerEnabled = true,
    this.themeMode = 'cyberpunk',
  });

  UserSettings copyWith({
    String? selectedSortOption,
    CarFilter? savedFilter,
    bool? notificationsEnabled,
    bool? qrScannerEnabled,
    String? themeMode,
  }) {
    return UserSettings(
      selectedSortOption: selectedSortOption ?? this.selectedSortOption,
      savedFilter: savedFilter ?? this.savedFilter,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      qrScannerEnabled: qrScannerEnabled ?? this.qrScannerEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedSortOption': selectedSortOption,
      'savedFilter': {
        'category': savedFilter.category,
        'minPrice': savedFilter.minPrice,
        'maxPrice': savedFilter.maxPrice,
        'minYear': savedFilter.minYear,
        'maxYear': savedFilter.maxYear,
        'fuelType': savedFilter.fuelType,
        'transmission': savedFilter.transmission,
        'minSeats': savedFilter.minSeats,
      },
      'notificationsEnabled': notificationsEnabled,
      'qrScannerEnabled': qrScannerEnabled,
      'themeMode': themeMode,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      selectedSortOption: json['selectedSortOption'] ?? 'price_low',
      savedFilter: CarFilter(
        category: json['savedFilter']?['category'] ?? '',
        minPrice: json['savedFilter']?['minPrice'] ?? 0.0,
        maxPrice: json['savedFilter']?['maxPrice'] ?? 1000.0,
        minYear: json['savedFilter']?['minYear'] ?? 2000,
        maxYear: json['savedFilter']?['maxYear'] ?? 2025,
        fuelType: json['savedFilter']?['fuelType'] ?? '',
        transmission: json['savedFilter']?['transmission'] ?? '',
        minSeats: json['savedFilter']?['minSeats'] ?? 2,
      ),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      qrScannerEnabled: json['qrScannerEnabled'] ?? true,
      themeMode: json['themeMode'] ?? 'cyberpunk',
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = UserSettings();
  bool _isLoading = false;
  late SharedPreferences _prefs;

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    final String? settingsJson = _prefs.getString('user_settings');

    if (settingsJson != null) {
      try {
        final Map<String, dynamic> settingsMap = Map<String, dynamic>.from(
          settingsJson as Map,
        );
        _settings = UserSettings.fromJson(settingsMap);
      } catch (e) {
        debugPrint('Error parsing settings: $e');
        _settings = UserSettings();
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final String settingsJson = _settings.toJson().toString();
      await _prefs.setString('user_settings', settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Update sort option
  Future<void> updateSortOption(String sortOption) async {
    if (!_isLoading && _prefs != null) {
      _settings = _settings.copyWith(selectedSortOption: sortOption);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Update filter settings
  Future<void> updateFilter(CarFilter filter) async {
    if (!_isLoading && _prefs != null) {
      _settings = _settings.copyWith(savedFilter: filter);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    if (!_isLoading && _prefs != null) {
      _settings = _settings.copyWith(notificationsEnabled: enabled);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Toggle QR scanner
  Future<void> toggleQRScanner(bool enabled) async {
    if (!_isLoading && _prefs != null) {
      _settings = _settings.copyWith(qrScannerEnabled: enabled);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Update theme mode
  Future<void> updateThemeMode(String themeMode) async {
    if (!_isLoading && _prefs != null) {
      _settings = _settings.copyWith(themeMode: themeMode);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Reset all settings to default
  Future<void> resetSettings() async {
    if (!_isLoading && _prefs != null) {
      _settings = UserSettings();
      await _saveSettings();
      notifyListeners();
    }
  }

  // Get current sort option
  String get currentSortOption => _settings.selectedSortOption;

  // Get saved filter
  CarFilter get savedFilter => _settings.savedFilter;

  // Check if notifications are enabled
  bool get notificationsEnabled => _settings.notificationsEnabled;

  // Check if QR scanner is enabled
  bool get qrScannerEnabled => _settings.qrScannerEnabled;

  // Get current theme mode
  String get themeMode => _settings.themeMode;
}
