import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/cyberpunk_theme.dart';
import '../widgets/cyberpunk_character.dart';
import '../providers/car_provider.dart';
import '../providers/settings_provider.dart';
import '../models/car_model.dart';

class CarListingScreen extends StatefulWidget {
  const CarListingScreen({super.key});

  @override
  State<CarListingScreen> createState() => _CarListingScreenState();
}

class _CarListingScreenState extends State<CarListingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showScrollToTop = _scrollController.offset > 300;
        });
      });

    // Apply saved filter and sort settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applySavedSettings();
    });
  }

  void _applySavedSettings() async {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final carProvider = Provider.of<CarProvider>(context, listen: false);

    // Wait a bit for settings to load
    await Future.delayed(const Duration(milliseconds: 100));

    // Only apply if settings are loaded and not loading
    if (!settingsProvider.isLoading) {
      // Apply saved filter
      if (settingsProvider.savedFilter.category.isNotEmpty ||
          settingsProvider.savedFilter.minPrice > 0 ||
          settingsProvider.savedFilter.fuelType.isNotEmpty ||
          settingsProvider.savedFilter.transmission.isNotEmpty) {
        carProvider.updateFilter(settingsProvider.savedFilter);
      }

      // Apply saved sort option
      if (settingsProvider.currentSortOption != 'price_low') {
        carProvider.sortCars(settingsProvider.currentSortOption);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CyberpunkTheme.neonText('VEHICLES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortDialog();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: CyberpunkTheme.backgroundGradient),
        child: Consumer<CarProvider>(
          builder: (context, carProvider, child) {
            if (carProvider.isLoading) {
              return const LoadingCyberpunkCharacter(
                message: 'Loading vehicles...',
              );
            }

            if (carProvider.filteredCars.isEmpty) {
              return const ErrorCyberpunkCharacter(
                message: 'No vehicles found matching your criteria',
                onRetry: null,
              );
            }

            return FadeTransition(
              opacity: _animationController,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: carProvider.filteredCars.length,
                itemBuilder: (context, index) {
                  return _buildCarCard(carProvider.filteredCars[index], index);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FadeIn(
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: CyberpunkTheme.primaryNeon,
                foregroundColor: CyberpunkTheme.darkBackground,
                child: const Icon(Icons.arrow_upward),
              ),
            )
          : null,
    );
  }

  Widget _buildCarCard(Car car, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: index * 100),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: CyberpunkTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CyberpunkTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: CyberpunkTheme.primaryNeon.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                imageUrl: car.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: CyberpunkTheme.darkSurface,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        CyberpunkTheme.primaryNeon,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Car details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.fullName,
                              style: TextStyle(
                                color: CyberpunkTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${car.year} • ${car.fuelType} • ${car.transmission}',
                              style: TextStyle(
                                color: CyberpunkTheme.textSecondary,
                                fontSize: 12,
                                fontFamily: 'Rajdhani',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            car.displayPrice,
                            style: TextStyle(
                              color: CyberpunkTheme.primaryNeon,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Orbitron',
                            ),
                          ),
                          Text(
                            'per day',
                            style: TextStyle(
                              color: CyberpunkTheme.textMuted,
                              fontSize: 10,
                              fontFamily: 'Rajdhani',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Rating and reviews
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        car.rating.toString(),
                        style: TextStyle(
                          color: CyberpunkTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '(${car.reviewCount} reviews)',
                        style: TextStyle(
                          color: CyberpunkTheme.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: car.isAvailable
                              ? CyberpunkTheme.accentNeon.withOpacity(0.2)
                              : CyberpunkTheme.errorNeon.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: car.isAvailable
                                ? CyberpunkTheme.accentNeon
                                : CyberpunkTheme.errorNeon,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          car.isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: car.isAvailable
                                ? CyberpunkTheme.accentNeon
                                : CyberpunkTheme.errorNeon,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Rajdhani',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Key specs
                  Row(
                    children: [
                      _buildSpecChip('${car.seats} seats', Icons.person),
                      const SizedBox(width: 10),
                      _buildSpecChip(
                        '${car.doors} doors',
                        Icons.door_front_door,
                      ),
                      const SizedBox(width: 10),
                      _buildSpecChip(car.color, Icons.color_lens),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Description
                  Text(
                    car.description,
                    style: TextStyle(
                      color: CyberpunkTheme.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Rajdhani',
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: car.isAvailable
                              ? () {
                                  Navigator.pushNamed(
                                    context,
                                    '/car-detail',
                                    arguments: car,
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CyberpunkTheme.primaryNeon,
                            side: const BorderSide(
                              color: CyberpunkTheme.primaryNeon,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: car.isAvailable
                              ? () {
                                  Navigator.pushNamed(
                                    context,
                                    '/booking',
                                    arguments: car,
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Book Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CyberpunkTheme.primaryNeon,
                            foregroundColor: CyberpunkTheme.darkBackground,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkSurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CyberpunkTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: CyberpunkTheme.primaryNeon, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: CyberpunkTheme.textPrimary,
              fontSize: 10,
              fontFamily: 'Rajdhani',
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(context: context, builder: (context) => const FilterDialog());
  }

  void _showSortDialog() {
    showDialog(context: context, builder: (context) => const SortDialog());
  }
}

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String selectedCategory;
  late double minPrice;
  late double maxPrice;
  late String selectedFuelType;
  late String selectedTransmission;
  late int minSeats;

  final List<String> categories = ['Electric', 'Sports', 'SUV', 'Supercar'];
  final List<String> fuelTypes = ['Electric', 'Gasoline', 'Hybrid'];
  final List<String> transmissions = ['Automatic', 'Manual'];

  @override
  void initState() {
    super.initState();
    _loadSavedFilterSettings();
  }

  void _loadSavedFilterSettings() async {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    // Wait for settings to load
    while (settingsProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Only update if settings are loaded
    if (!settingsProvider.isLoading) {
      final savedFilter = settingsProvider.savedFilter;

      setState(() {
        selectedCategory = savedFilter.category;
        minPrice = savedFilter.minPrice;
        maxPrice = savedFilter.maxPrice;
        selectedFuelType = savedFilter.fuelType;
        selectedTransmission = savedFilter.transmission;
        minSeats = savedFilter.minSeats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Dialog(
      backgroundColor: CyberpunkTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: CyberpunkTheme.borderColor),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Vehicles',
                style: TextStyle(
                  color: CyberpunkTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                ),
              ),
              const SizedBox(height: 20),

              // Category Filter
              Text(
                'Category',
                style: TextStyle(
                  color: CyberpunkTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Rajdhani',
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = selected ? category : '';
                      });
                    },
                    selectedColor: CyberpunkTheme.primaryNeon.withOpacity(0.3),
                    checkmarkColor: CyberpunkTheme.primaryNeon,
                    labelStyle: TextStyle(
                      color: selectedCategory == category
                          ? CyberpunkTheme.primaryNeon
                          : CyberpunkTheme.textPrimary,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Price Range
              Text(
                'Price Range: \$${minPrice.toInt()} - \$${maxPrice.toInt()}',
                style: TextStyle(
                  color: CyberpunkTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Rajdhani',
                ),
              ),
              RangeSlider(
                values: RangeValues(minPrice, maxPrice),
                min: 0,
                max: 1000,
                divisions: 20,
                activeColor: CyberpunkTheme.primaryNeon,
                inactiveColor: CyberpunkTheme.borderColor,
                onChanged: (values) {
                  setState(() {
                    minPrice = values.start;
                    maxPrice = values.end;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Fuel Type
              Text(
                'Fuel Type',
                style: TextStyle(
                  color: CyberpunkTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Rajdhani',
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: fuelTypes.map((fuel) {
                  return FilterChip(
                    label: Text(fuel),
                    selected: selectedFuelType == fuel,
                    onSelected: (selected) {
                      setState(() {
                        selectedFuelType = selected ? fuel : '';
                      });
                    },
                    selectedColor: CyberpunkTheme.secondaryNeon.withOpacity(
                      0.3,
                    ),
                    checkmarkColor: CyberpunkTheme.secondaryNeon,
                    labelStyle: TextStyle(
                      color: selectedFuelType == fuel
                          ? CyberpunkTheme.secondaryNeon
                          : CyberpunkTheme.textPrimary,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Transmission
              Text(
                'Transmission',
                style: TextStyle(
                  color: CyberpunkTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Rajdhani',
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: transmissions.map((transmission) {
                  return FilterChip(
                    label: Text(transmission),
                    selected: selectedTransmission == transmission,
                    onSelected: (selected) {
                      setState(() {
                        selectedTransmission = selected ? transmission : '';
                      });
                    },
                    selectedColor: CyberpunkTheme.accentNeon.withOpacity(0.3),
                    checkmarkColor: CyberpunkTheme.accentNeon,
                    labelStyle: TextStyle(
                      color: selectedTransmission == transmission
                          ? CyberpunkTheme.accentNeon
                          : CyberpunkTheme.textPrimary,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Minimum Seats
              Text(
                'Minimum Seats: $minSeats',
                style: TextStyle(
                  color: CyberpunkTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Rajdhani',
                ),
              ),
              Slider(
                value: minSeats.toDouble(),
                min: 2,
                max: 7,
                divisions: 5,
                activeColor: CyberpunkTheme.warningNeon,
                onChanged: (value) {
                  setState(() {
                    minSeats = value.toInt();
                  });
                },
              ),

              const SizedBox(height: 30),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = '';
                          minPrice = 0;
                          maxPrice = 1000;
                          selectedFuelType = '';
                          selectedTransmission = '';
                          minSeats = 2;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CyberpunkTheme.textSecondary,
                        side: const BorderSide(
                          color: CyberpunkTheme.textSecondary,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final filter = CarFilter(
                          category: selectedCategory,
                          minPrice: minPrice,
                          maxPrice: maxPrice,
                          fuelType: selectedFuelType,
                          transmission: selectedTransmission,
                          minSeats: minSeats,
                        );
                        carProvider.updateFilter(filter);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CyberpunkTheme.primaryNeon,
                        foregroundColor: CyberpunkTheme.darkBackground,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SortDialog extends StatefulWidget {
  const SortDialog({super.key});

  @override
  State<SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  late String _selectedSortOption;

  final Map<String, String> sortOptions = {
    'price_low': 'Price: Low to High',
    'price_high': 'Price: High to Low',
    'rating': 'Highest Rated',
    'year_new': 'Newest First',
    'year_old': 'Oldest First',
    'name_az': 'Name: A to Z',
    'name_za': 'Name: Z to A',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSortOption();
  }

  void _loadSavedSortOption() async {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    // Wait for settings to load
    while (settingsProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Only update if settings are loaded
    if (!settingsProvider.isLoading) {
      setState(() {
        _selectedSortOption = settingsProvider.currentSortOption;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);

    return Dialog(
      backgroundColor: CyberpunkTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: CyberpunkTheme.borderColor),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Vehicles',
              style: TextStyle(
                color: CyberpunkTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
            const SizedBox(height: 20),

            // Sort options
            ...sortOptions.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _selectedSortOption == entry.key
                      ? CyberpunkTheme.primaryNeon.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedSortOption == entry.key
                        ? CyberpunkTheme.primaryNeon
                        : CyberpunkTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      color: _selectedSortOption == entry.key
                          ? CyberpunkTheme.primaryNeon
                          : CyberpunkTheme.textPrimary,
                      fontFamily: 'Rajdhani',
                    ),
                  ),
                  leading: Radio<String>(
                    value: entry.key,
                    groupValue: _selectedSortOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedSortOption = value!;
                      });
                    },
                    activeColor: CyberpunkTheme.primaryNeon,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedSortOption = entry.key;
                    });
                  },
                ),
              );
            }),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CyberpunkTheme.textSecondary,
                      side: const BorderSide(
                        color: CyberpunkTheme.textSecondary,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _applySort(carProvider);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberpunkTheme.primaryNeon,
                      foregroundColor: CyberpunkTheme.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Apply Sort'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applySort(CarProvider carProvider) {
    carProvider.sortCars(_selectedSortOption);
  }
}
