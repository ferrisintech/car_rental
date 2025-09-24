import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../data/sample_data.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  List<Booking> _userBookings = [];
  List<Review> _userReviews = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  List<Booking> get userBookings => _userBookings;
  List<Review> get userReviews => _userReviews;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initializeData();
  }

  void _initializeData() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _currentUser = SampleData.getSampleUser();
      _userBookings = SampleData.getSampleBookings();
      _userReviews = SampleData.getSampleReviews();
      _isLoading = false;
      notifyListeners();
    });
  }

  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateUserPreferences(UserPreferences preferences) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        avatarUrl: _currentUser!.avatarUrl,
        memberSince: _currentUser!.memberSince,
        totalBookings: _currentUser!.totalBookings,
        totalSpent: _currentUser!.totalSpent,
        membershipTier: _currentUser!.membershipTier,
        favoriteCars: _currentUser!.favoriteCars,
        preferences: preferences,
      );
      notifyListeners();
    }
  }

  void addToFavorites(String carId) {
    if (_currentUser != null && !_currentUser!.favoriteCars.contains(carId)) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        avatarUrl: _currentUser!.avatarUrl,
        memberSince: _currentUser!.memberSince,
        totalBookings: _currentUser!.totalBookings,
        totalSpent: _currentUser!.totalSpent,
        membershipTier: _currentUser!.membershipTier,
        favoriteCars: [..._currentUser!.favoriteCars, carId],
        preferences: _currentUser!.preferences,
      );
      notifyListeners();
    }
  }

  void removeFromFavorites(String carId) {
    if (_currentUser != null && _currentUser!.favoriteCars.contains(carId)) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        avatarUrl: _currentUser!.avatarUrl,
        memberSince: _currentUser!.memberSince,
        totalBookings: _currentUser!.totalBookings,
        totalSpent: _currentUser!.totalSpent,
        membershipTier: _currentUser!.membershipTier,
        favoriteCars: _currentUser!.favoriteCars
            .where((id) => id != carId)
            .toList(),
        preferences: _currentUser!.preferences,
      );
      notifyListeners();
    }
  }

  bool isFavorite(String carId) {
    return _currentUser?.favoriteCars.contains(carId) ?? false;
  }

  void addBooking(Booking booking) {
    _userBookings.add(booking);
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        avatarUrl: _currentUser!.avatarUrl,
        memberSince: _currentUser!.memberSince,
        totalBookings: _currentUser!.totalBookings + 1,
        totalSpent: _currentUser!.totalSpent + booking.totalPrice,
        membershipTier: _currentUser!.membershipTier,
        favoriteCars: _currentUser!.favoriteCars,
        preferences: _currentUser!.preferences,
      );
    }
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, String status) {
    final index = _userBookings.indexWhere(
      (booking) => booking.id == bookingId,
    );
    if (index != -1) {
      _userBookings[index] = Booking(
        id: _userBookings[index].id,
        carId: _userBookings[index].carId,
        userId: _userBookings[index].userId,
        startDate: _userBookings[index].startDate,
        endDate: _userBookings[index].endDate,
        totalPrice: _userBookings[index].totalPrice,
        status: status,
        pickupLocation: _userBookings[index].pickupLocation,
        dropoffLocation: _userBookings[index].dropoffLocation,
        createdAt: _userBookings[index].createdAt,
        additionalServices: _userBookings[index].additionalServices,
      );
      notifyListeners();
    }
  }

  void addReview(Review review) {
    _userReviews.add(review);
    notifyListeners();
  }

  List<Booking> getActiveBookings() {
    return _userBookings.where((booking) => booking.isActive).toList();
  }

  List<Booking> getCompletedBookings() {
    return _userBookings.where((booking) => booking.isCompleted).toList();
  }

  List<Booking> getUpcomingBookings() {
    final now = DateTime.now();
    return _userBookings
        .where((booking) => booking.startDate.isAfter(now) && booking.isActive)
        .toList();
  }

  void signOut() {
    _currentUser = null;
    _userBookings = [];
    _userReviews = [];
    notifyListeners();
  }

  void refreshData() {
    _initializeData();
  }
}
