import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/cyberpunk_theme.dart';
import '../widgets/cyberpunk_character.dart';
import '../models/car_model.dart';

class CarDetailScreen extends StatefulWidget {
  const CarDetailScreen({super.key});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _imageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _imageController = PageController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Car car = ModalRoute.of(context)!.settings.arguments as Car;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: CyberpunkTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: CyberpunkTheme.darkSurface,
              foregroundColor: CyberpunkTheme.textPrimary,
              title: CyberpunkTheme.neonText(car.fullName),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageGallery(car),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added to favorites!',
                          style: TextStyle(color: CyberpunkTheme.textPrimary),
                        ),
                        backgroundColor: CyberpunkTheme.darkSurface,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Share link copied to clipboard!',
                          style: TextStyle(color: CyberpunkTheme.textPrimary),
                        ),
                        backgroundColor: CyberpunkTheme.darkSurface,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _animationController,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price and rating
                      _buildPriceAndRating(car),

                      const SizedBox(height: 30),

                      // Key specifications
                      _buildSpecifications(car),

                      const SizedBox(height: 30),

                      // Description
                      _buildDescription(car),

                      const SizedBox(height: 30),

                      // Features
                      _buildFeatures(car),

                      const SizedBox(height: 40),

                      // Action buttons
                      _buildActionButtons(car),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(Car car) {
    return Stack(
      children: [
        PageView.builder(
          controller: _imageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: car.galleryImages.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: car.galleryImages[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: CyberpunkTheme.darkSurface,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                      CyberpunkTheme.primaryNeon,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Image indicators
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              car.galleryImages.length,
              (index) => _buildImageIndicator(index),
            ),
          ),
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                CyberpunkTheme.darkBackground.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: _currentImageIndex == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentImageIndex == index
            ? CyberpunkTheme.primaryNeon
            : CyberpunkTheme.textSecondary,
        borderRadius: BorderRadius.circular(4),
        boxShadow: _currentImageIndex == index
            ? [
                BoxShadow(
                  color: CyberpunkTheme.primaryNeon.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildPriceAndRating(Car car) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              car.displayPrice,
              style: TextStyle(
                color: CyberpunkTheme.primaryNeon,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
            Text(
              'per day',
              style: TextStyle(
                color: CyberpunkTheme.textSecondary,
                fontSize: 14,
                fontFamily: 'Rajdhani',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 5),
            Text(
              car.rating.toString(),
              style: TextStyle(
                color: CyberpunkTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Rajdhani',
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '(${car.reviewCount})',
              style: TextStyle(
                color: CyberpunkTheme.textSecondary,
                fontSize: 14,
                fontFamily: 'Rajdhani',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecifications(Car car) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _buildSpecCard('Year', car.year.toString(), Icons.calendar_today),
            _buildSpecCard('Fuel', car.fuelType, Icons.local_gas_station),
            _buildSpecCard('Transmission', car.transmission, Icons.settings),
            _buildSpecCard('Seats', '${car.seats} seats', Icons.person),
            _buildSpecCard(
              'Doors',
              '${car.doors} doors',
              Icons.door_front_door,
            ),
            _buildSpecCard('Color', car.color, Icons.color_lens),
            _buildSpecCard('Engine', '${car.engineSize}L', Icons.build),
            _buildSpecCard(
              'Mileage',
              '${car.mileage.toString()} km',
              Icons.speed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecCard(String title, String value, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width - 55) / 2,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CyberpunkTheme.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: CyberpunkTheme.primaryNeon, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: CyberpunkTheme.textSecondary,
              fontSize: 12,
              fontFamily: 'Rajdhani',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: CyberpunkTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Rajdhani',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Car car) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 15),
        Text(
          car.description,
          style: TextStyle(
            color: CyberpunkTheme.textSecondary,
            fontSize: 16,
            fontFamily: 'Rajdhani',
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(Car car) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: car.features.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: CyberpunkTheme.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CyberpunkTheme.primaryNeon, width: 1),
              ),
              child: Text(
                feature,
                style: TextStyle(
                  color: CyberpunkTheme.primaryNeon,
                  fontSize: 12,
                  fontFamily: 'Rajdhani',
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Car car) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/booking', arguments: car);
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text('Book Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberpunkTheme.primaryNeon,
              foregroundColor: CyberpunkTheme.darkBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.message),
            label: const Text('Contact Dealer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CyberpunkTheme.primaryNeon,
              side: const BorderSide(
                color: CyberpunkTheme.primaryNeon,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
