import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/cyberpunk_theme.dart';
import '../widgets/cyberpunk_character.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _avatarController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _avatarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CyberpunkTheme.neonText('PROFILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: CyberpunkTheme.backgroundGradient),
        child: FadeTransition(
          opacity: _animationController,
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.currentUser;
              if (user == null) {
                return const LoadingCyberpunkCharacter(
                  message: 'Loading profile...',
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile header
                    _buildProfileHeader(user),

                    const SizedBox(height: 30),

                    // Stats cards
                    _buildStatsCards(user),

                    const SizedBox(height: 30),

                    // Membership info
                    _buildMembershipCard(user),

                    const SizedBox(height: 30),

                    // Favorite cars
                    _buildFavoriteCars(userProvider),

                    const SizedBox(height: 30),

                    // Recent bookings
                    _buildRecentBookings(userProvider),

                    const SizedBox(height: 30),

                    // Account actions
                    _buildAccountActions(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: CyberpunkTheme.primaryGradient,
        borderRadius: BorderRadius.circular(25),
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
          // Avatar with animation
          AnimatedBuilder(
            animation: _avatarController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_avatarController.value * 0.1),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CyberpunkTheme.darkBackground,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CyberpunkTheme.primaryNeon.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 37,
                    backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 20),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    color: CyberpunkTheme.darkBackground,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.email,
                  style: TextStyle(
                    color: CyberpunkTheme.darkBackground.withOpacity(0.8),
                    fontSize: 14,
                    fontFamily: 'Rajdhani',
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.isPremium
                        ? CyberpunkTheme.accentNeon.withOpacity(0.2)
                        : CyberpunkTheme.secondaryNeon.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: user.isPremium
                          ? CyberpunkTheme.accentNeon
                          : CyberpunkTheme.secondaryNeon,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    user.membershipTier,
                    style: TextStyle(
                      color: user.isPremium
                          ? CyberpunkTheme.accentNeon
                          : CyberpunkTheme.secondaryNeon,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rajdhani',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            onPressed: () {
              _showEditProfileDialog(user);
            },
            icon: Icon(Icons.edit, color: CyberpunkTheme.darkBackground),
            style: IconButton.styleFrom(
              backgroundColor: CyberpunkTheme.darkBackground.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(User user) {
    return Row(
      children: [
        _buildStatCard(
          'Total Bookings',
          user.totalBookings.toString(),
          Icons.calendar_today,
          CyberpunkTheme.primaryNeon,
        ),
        const SizedBox(width: 15),
        _buildStatCard(
          'Total Spent',
          '\$${user.totalSpent.toStringAsFixed(0)}',
          Icons.attach_money,
          CyberpunkTheme.secondaryNeon,
        ),
        const SizedBox(width: 15),
        _buildStatCard(
          'Member Since',
          user.memberSince,
          Icons.star,
          CyberpunkTheme.accentNeon,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: CyberpunkTheme.textSecondary,
                fontSize: 10,
                fontFamily: 'Rajdhani',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCard(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CyberpunkTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Membership Benefits',
                style: TextStyle(
                  color: CyberpunkTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                ),
              ),
              Icon(
                user.isPremium ? Icons.diamond : Icons.card_membership,
                color: user.isPremium
                    ? CyberpunkTheme.accentNeon
                    : CyberpunkTheme.primaryNeon,
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (user.isPremium) ...[
            _buildBenefitItem('Priority booking access', Icons.flash_on),
            _buildBenefitItem('Free upgrades when available', Icons.upgrade),
            _buildBenefitItem('Dedicated support line', Icons.support_agent),
            _buildBenefitItem('Exclusive discounts', Icons.percent),
          ] else ...[
            _buildBenefitItem('Standard booking access', Icons.access_time),
            _buildBenefitItem('Regular support', Icons.help),
            _buildBenefitItem('Standard rates', Icons.attach_money),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  _showUpgradeDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberpunkTheme.accentNeon,
                  foregroundColor: CyberpunkTheme.darkBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Upgrade to Premium'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: CyberpunkTheme.primaryNeon, size: 16),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: CyberpunkTheme.textSecondary,
              fontSize: 14,
              fontFamily: 'Rajdhani',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCars(UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Cars',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 15),
        userProvider.currentUser!.favoriteCars.isEmpty
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.darkCard,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: CyberpunkTheme.borderColor),
                ),
                child: Center(
                  child: Text(
                    'No favorite cars yet',
                    style: TextStyle(
                      color: CyberpunkTheme.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Rajdhani',
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: userProvider.currentUser!.favoriteCars.length,
                  itemBuilder: (context, index) {
                    return _buildFavoriteCarCard(
                      userProvider.currentUser!.favoriteCars[index],
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildFavoriteCarCard(String carId) {
    // This would normally fetch the car from the provider
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CyberpunkTheme.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, color: CyberpunkTheme.errorNeon, size: 24),
          const SizedBox(height: 5),
          Text(
            'Tesla Model S',
            style: TextStyle(
              color: CyberpunkTheme.textPrimary,
              fontSize: 10,
              fontFamily: 'Rajdhani',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookings(UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
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
              Icon(Icons.history, color: CyberpunkTheme.primaryNeon, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last booking: Tesla Model S',
                      style: TextStyle(
                        color: CyberpunkTheme.textPrimary,
                        fontSize: 14,
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
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        _buildActionButton('My Bookings', Icons.calendar_today, () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'My Bookings - Coming Soon!',
                style: TextStyle(color: CyberpunkTheme.textPrimary),
              ),
              backgroundColor: CyberpunkTheme.darkSurface,
              duration: const Duration(seconds: 2),
            ),
          );
        }),
        const SizedBox(height: 15),
        _buildActionButton('Payment Methods', Icons.credit_card, () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment Methods - Coming Soon!',
                style: TextStyle(color: CyberpunkTheme.textPrimary),
              ),
              backgroundColor: CyberpunkTheme.darkSurface,
              duration: const Duration(seconds: 2),
            ),
          );
        }),
        const SizedBox(height: 15),
        _buildActionButton('Support', Icons.support_agent, () {
          _showSupportDialog();
        }),
        const SizedBox(height: 15),
        _buildActionButton('Sign Out', Icons.logout, () {
          _showSignOutDialog();
        }, isDestructive: true),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDestructive
              ? CyberpunkTheme.errorNeon
              : CyberpunkTheme.primaryNeon,
          side: BorderSide(
            color: isDestructive
                ? CyberpunkTheme.errorNeon
                : CyberpunkTheme.primaryNeon,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.darkSurface,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: CyberpunkTheme.textPrimary),
        ),
        content: Text(
          'Profile editing would be implemented here.',
          style: TextStyle(color: CyberpunkTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: CyberpunkTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Save',
              style: TextStyle(color: CyberpunkTheme.primaryNeon),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.darkSurface,
        title: Text(
          'Settings',
          style: TextStyle(color: CyberpunkTheme.textPrimary),
        ),
        content: Text(
          'Settings panel would be implemented here.',
          style: TextStyle(color: CyberpunkTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: CyberpunkTheme.primaryNeon),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.darkSurface,
        title: Text(
          'Upgrade to Premium',
          style: TextStyle(color: CyberpunkTheme.textPrimary),
        ),
        content: Text(
          'Premium membership offers exclusive benefits and priority access.',
          style: TextStyle(color: CyberpunkTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: CyberpunkTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Upgrade Now',
              style: TextStyle(color: CyberpunkTheme.accentNeon),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.darkSurface,
        title: Text(
          'Support',
          style: TextStyle(color: CyberpunkTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Need help? Contact our support team:',
              style: TextStyle(color: CyberpunkTheme.textSecondary),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: Icon(Icons.email, color: CyberpunkTheme.primaryNeon),
              title: Text(
                'support@cyberrent.com',
                style: TextStyle(color: CyberpunkTheme.textPrimary),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Email copied to clipboard!',
                      style: TextStyle(color: CyberpunkTheme.textPrimary),
                    ),
                    backgroundColor: CyberpunkTheme.darkSurface,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: CyberpunkTheme.secondaryNeon),
              title: Text(
                '+1 (555) 123-4567',
                style: TextStyle(color: CyberpunkTheme.textPrimary),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Phone number copied to clipboard!',
                      style: TextStyle(color: CyberpunkTheme.textPrimary),
                    ),
                    backgroundColor: CyberpunkTheme.darkSurface,
                  ),
                );
              },
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
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.darkSurface,
        title: Text(
          'Sign Out',
          style: TextStyle(color: CyberpunkTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: CyberpunkTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: CyberpunkTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Sign out logic would go here
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: CyberpunkTheme.errorNeon),
            ),
          ),
        ],
      ),
    );
  }
}
