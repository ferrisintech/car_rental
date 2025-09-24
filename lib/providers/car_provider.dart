import 'package:flutter/foundation.dart';
import '../models/car_model.dart';
import '../data/sample_data.dart';
import 'settings_provider.dart';

class CarProvider extends ChangeNotifier {
  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  CarFilter _currentFilter = CarFilter();
  bool _isLoading = false;
  String _searchQuery = '';

  List<Car> get cars => _cars;
  List<Car> get filteredCars => _filteredCars;
  CarFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  CarProvider() {
    _initializeData();
  }

  void _initializeData() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _cars = SampleData.getSampleCars();
      _filteredCars = _cars;
      _isLoading = false;
      notifyListeners();
    });
  }

  void searchCars(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void updateFilter(CarFilter filter) {
    _currentFilter = filter;
    _applyFilters();

    // Save filter to settings
    final settingsProvider = SettingsProvider();
    settingsProvider.updateFilter(filter);
  }

  void _applyFilters() {
    List<Car> filtered = _cars.where((car) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!car.name.toLowerCase().contains(query) &&
            !car.brand.toLowerCase().contains(query) &&
            !car.model.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (_currentFilter.category.isNotEmpty &&
          car.category != _currentFilter.category) {
        return false;
      }

      // Price filter
      if (car.pricePerDay < _currentFilter.minPrice ||
          car.pricePerDay > _currentFilter.maxPrice) {
        return false;
      }

      // Year filter
      if (car.year < _currentFilter.minYear ||
          car.year > _currentFilter.maxYear) {
        return false;
      }

      // Fuel type filter
      if (_currentFilter.fuelType.isNotEmpty &&
          car.fuelType != _currentFilter.fuelType) {
        return false;
      }

      // Transmission filter
      if (_currentFilter.transmission.isNotEmpty &&
          car.transmission != _currentFilter.transmission) {
        return false;
      }

      // Seats filter
      if (car.seats < _currentFilter.minSeats) {
        return false;
      }

      return true;
    }).toList();

    _filteredCars = filtered;
    notifyListeners();
  }

  Car? getCarById(String id) {
    try {
      return _cars.firstWhere((car) => car.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Car> getAvailableCars() {
    return _cars.where((car) => car.isAvailable).toList();
  }

  List<Car> getCarsByCategory(String category) {
    return _cars.where((car) => car.category == category).toList();
  }

  List<String> getCategories() {
    return _cars.map((car) => car.category).toSet().toList();
  }

  List<String> getFuelTypes() {
    return _cars.map((car) => car.fuelType).toSet().toList();
  }

  List<String> getTransmissions() {
    return _cars.map((car) => car.transmission).toSet().toList();
  }

  void toggleCarAvailability(String carId) {
    final index = _cars.indexWhere((car) => car.id == carId);
    if (index != -1) {
      _cars[index] = Car(
        id: _cars[index].id,
        name: _cars[index].name,
        brand: _cars[index].brand,
        model: _cars[index].model,
        imageUrl: _cars[index].imageUrl,
        galleryImages: _cars[index].galleryImages,
        pricePerDay: _cars[index].pricePerDay,
        category: _cars[index].category,
        year: _cars[index].year,
        fuelType: _cars[index].fuelType,
        transmission: _cars[index].transmission,
        seats: _cars[index].seats,
        doors: _cars[index].doors,
        color: _cars[index].color,
        engineSize: _cars[index].engineSize,
        mileage: _cars[index].mileage,
        description: _cars[index].description,
        features: _cars[index].features,
        rating: _cars[index].rating,
        reviewCount: _cars[index].reviewCount,
        isAvailable: !_cars[index].isAvailable,
      );
      _applyFilters();
    }
  }

  void refreshData() {
    _initializeData();
  }

  // Public methods for sorting
  void sortCars(String sortOption) {
    switch (sortOption) {
      case 'price_low':
        _cars.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'price_high':
        _cars.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'rating':
        _cars.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'year_new':
        _cars.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'year_old':
        _cars.sort((a, b) => a.year.compareTo(b.year));
        break;
      case 'name_az':
        _cars.sort(
          (a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
        break;
      case 'name_za':
        _cars.sort(
          (a, b) =>
              b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()),
        );
        break;
    }
    _applyFilters();

    // Save sort option to settings
    final settingsProvider = SettingsProvider();
    settingsProvider.updateSortOption(sortOption);
  }

  void resetSort() {
    _initializeData();
  }
}
