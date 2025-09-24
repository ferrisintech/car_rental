import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/cyberpunk_theme.dart';
import '../widgets/cyberpunk_character.dart';
import '../providers/car_provider.dart';
import '../providers/user_provider.dart';
import '../models/car_model.dart';
import 'car_listing_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const CarListingScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeController,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkSurface,
        border: Border(
          top: BorderSide(color: CyberpunkTheme.borderColor, width: 1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _slideController.forward(from: 0);
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: CyberpunkTheme.primaryNeon,
          unselectedItemColor: CyberpunkTheme.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          enableFeedback: false,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.electric_car, 1),
              label: 'Cars',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person, 2),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(_currentIndex == index ? 8 : 0),
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? CyberpunkTheme.primaryNeon.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: _currentIndex == index
            ? Border.all(color: CyberpunkTheme.primaryNeon, width: 1)
            : null,
      ),
      child: Icon(icon),
    );
  }

  Widget _buildFloatingActionButton() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
          ),
      child: FloatingActionButton(
        onPressed: () {
          // Quick search action
          showSearch(context: context, delegate: CarSearchDelegate());
        },
        backgroundColor: CyberpunkTheme.primaryNeon,
        foregroundColor: CyberpunkTheme.darkBackground,
        child: const Icon(Icons.search),
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CyberpunkTheme.neonText('CYBER RENT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotificationsDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              _showQRScanner(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: CyberpunkTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(),

              const SizedBox(height: 30),

              // Quick stats
              _buildQuickStats(),

              const SizedBox(height: 30),

              // Featured cars
              _buildFeaturedCars(),

              const SizedBox(height: 30),

              // Categories
              _buildCategories(),

              const SizedBox(height: 30),

              // Recent bookings
              _buildRecentBookings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        return FadeInDown(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: CyberpunkTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: CyberpunkTheme.primaryNeon.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: CyberpunkTheme.darkBackground,
                          fontSize: 16,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                      Text(
                        user?.displayName ?? 'Guest',
                        style: TextStyle(
                          color: CyberpunkTheme.darkBackground,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user?.isPremium == true
                            ? 'Premium Member'
                            : 'Ready for your next adventure?',
                        style: TextStyle(
                          color: CyberpunkTheme.darkBackground.withOpacity(0.8),
                          fontSize: 14,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                    ],
                  ),
                ),
                CyberpunkCharacter(size: 80, isAnimated: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: TextStyle(
              color: CyberpunkTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard('Available Cars', '50+', Icons.electric_car),
              const SizedBox(width: 15),
              _buildStatCard('Active Bookings', '12', Icons.calendar_today),
              const SizedBox(width: 15),
              _buildStatCard('Total Spent', '\$3,450', Icons.attach_money),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
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
              value,
              style: TextStyle(
                color: CyberpunkTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: CyberpunkTheme.textSecondary,
                fontSize: 12,
                fontFamily: 'Rajdhani',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCars() {
    return Consumer<CarProvider>(
      builder: (context, carProvider, child) {
        final featuredCars = carProvider.cars.take(3).toList();

        return FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Cars',
                    style: TextStyle(
                      color: CyberpunkTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to car listing screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CarListingScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: CyberpunkTheme.primaryNeon,
                        fontFamily: 'Rajdhani',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredCars.length,
                  itemBuilder: (context, index) {
                    return _buildFeaturedCarCard(featuredCars[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCarCard(Car car) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CyberpunkTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: CachedNetworkImage(
              imageUrl: car.imageUrl,
              height: 100,
              width: 160,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.fullName,
                  style: TextStyle(
                    color: CyberpunkTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rajdhani',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  car.displayPrice,
                  style: TextStyle(
                    color: CyberpunkTheme.primaryNeon,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              color: CyberpunkTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildCategoryChip(
                'Electric',
                Icons.electric_car,
                CyberpunkTheme.primaryNeon,
              ),
              const SizedBox(width: 10),
              _buildCategoryChip(
                'Sports',
                Icons.speed,
                CyberpunkTheme.secondaryNeon,
              ),
              const SizedBox(width: 10),
              _buildCategoryChip(
                'SUV',
                Icons.terrain,
                CyberpunkTheme.accentNeon,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Rajdhani',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookings() {
    return FadeInUp(
      delay: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Bookings',
            style: TextStyle(
              color: CyberpunkTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: CyberpunkTheme.darkCard,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: CyberpunkTheme.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: CyberpunkTheme.primaryNeon,
                  size: 24,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tesla Model S',
                        style: TextStyle(
                          color: CyberpunkTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                      Text(
                        'Dec 15 - Dec 18, 2024',
                        style: TextStyle(
                          color: CyberpunkTheme.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$360',
                  style: TextStyle(
                    color: CyberpunkTheme.primaryNeon,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.darkSurface,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontFamily: 'Orbitron',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.local_offer,
                color: CyberpunkTheme.primaryNeon,
              ),
              title: Text(
                'Special Offer: 20% off Electric Cars',
                style: TextStyle(color: CyberpunkTheme.textPrimary),
              ),
              subtitle: Text(
                'Limited time offer - expires in 2 days',
                style: TextStyle(color: CyberpunkTheme.textSecondary),
              ),
            ),
            const Divider(color: CyberpunkTheme.borderColor),
            ListTile(
              leading: Icon(Icons.update, color: CyberpunkTheme.secondaryNeon),
              title: Text(
                'New Cars Available',
                style: TextStyle(color: CyberpunkTheme.textPrimary),
              ),
              subtitle: Text(
                '5 new Tesla models added to our fleet',
                style: TextStyle(color: CyberpunkTheme.textSecondary),
              ),
            ),
            const Divider(color: CyberpunkTheme.borderColor),
            ListTile(
              leading: Icon(Icons.star, color: CyberpunkTheme.accentNeon),
              title: Text(
                'Premium Member Benefits',
                style: TextStyle(color: CyberpunkTheme.textPrimary),
              ),
              subtitle: Text(
                'Priority booking and free upgrades available',
                style: TextStyle(color: CyberpunkTheme.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: CyberpunkTheme.primaryNeon),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Mark All Read',
              style: TextStyle(color: CyberpunkTheme.accentNeon),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.darkSurface,
        title: Text(
          'QR Scanner',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontFamily: 'Orbitron',
          ),
        ),
        content: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: CyberpunkTheme.darkBackground,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: CyberpunkTheme.primaryNeon, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 80,
                color: CyberpunkTheme.primaryNeon,
              ),
              const SizedBox(height: 20),
              Text(
                'Point camera at QR code',
                style: TextStyle(
                  color: CyberpunkTheme.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Rajdhani',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Scan car barcode for quick pickup',
                style: TextStyle(
                  color: CyberpunkTheme.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Rajdhani',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'QR Code detected: Tesla Model S',
                            style: TextStyle(color: CyberpunkTheme.textPrimary),
                          ),
                          backgroundColor: CyberpunkTheme.darkSurface,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.flash_on,
                      color: CyberpunkTheme.warningNeon,
                    ),
                    tooltip: 'Flash',
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'QR Code detected: BMW i8',
                            style: TextStyle(color: CyberpunkTheme.textPrimary),
                          ),
                          backgroundColor: CyberpunkTheme.darkSurface,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.camera_alt,
                      color: CyberpunkTheme.primaryNeon,
                    ),
                    tooltip: 'Capture',
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: CyberpunkTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class CarSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    final suggestions = carProvider.cars.where((car) {
      return car.name.toLowerCase().contains(query.toLowerCase()) ||
          car.brand.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Container(
      color: CyberpunkTheme.darkBackground,
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final car = suggestions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(car.imageUrl),
            ),
            title: Text(
              car.fullName,
              style: TextStyle(color: CyberpunkTheme.textPrimary),
            ),
            subtitle: Text(
              car.displayPrice,
              style: TextStyle(color: CyberpunkTheme.primaryNeon),
            ),
            onTap: () {
              close(context, car);
              Navigator.pushNamed(context, '/car-detail', arguments: car);
            },
          );
        },
      ),
    );
  }
}
