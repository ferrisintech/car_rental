import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String memberSince;
  final int totalBookings;
  final double totalSpent;
  final String membershipTier;
  final List<String> favoriteCars;
  final UserPreferences preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.memberSince,
    required this.totalBookings,
    required this.totalSpent,
    required this.membershipTier,
    required this.favoriteCars,
    required this.preferences,
  });

  String get displayName => name.isNotEmpty ? name : 'Guest User';
  bool get isPremium => membershipTier == 'Premium' || membershipTier == 'VIP';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'memberSince': memberSince,
      'totalBookings': totalBookings,
      'totalSpent': totalSpent,
      'membershipTier': membershipTier,
      'favoriteCars': favoriteCars,
      'preferences': preferences.toJson(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
      memberSince: json['memberSince'],
      totalBookings: json['totalBookings'],
      totalSpent: json['totalSpent'].toDouble(),
      membershipTier: json['membershipTier'],
      favoriteCars: List<String>.from(json['favoriteCars']),
      preferences: UserPreferences.fromJson(json['preferences']),
    );
  }
}

class UserPreferences {
  final bool notificationsEnabled;
  final bool darkMode;
  final String language;
  final String currency;
  final bool biometricAuth;
  final List<String> preferredCategories;
  final double maxPriceRange;

  UserPreferences({
    this.notificationsEnabled = true,
    this.darkMode = true,
    this.language = 'en',
    this.currency = 'USD',
    this.biometricAuth = false,
    this.preferredCategories = const [],
    this.maxPriceRange = 500,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkMode': darkMode,
      'language': language,
      'currency': currency,
      'biometricAuth': biometricAuth,
      'preferredCategories': preferredCategories,
      'maxPriceRange': maxPriceRange,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      darkMode: json['darkMode'] ?? true,
      language: json['language'] ?? 'en',
      currency: json['currency'] ?? 'USD',
      biometricAuth: json['biometricAuth'] ?? false,
      preferredCategories: List<String>.from(json['preferredCategories'] ?? []),
      maxPriceRange: json['maxPriceRange']?.toDouble() ?? 500,
    );
  }
}

class Booking {
  final String id;
  final String carId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime createdAt;
  final Map<String, dynamic> additionalServices;

  Booking({
    required this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.createdAt,
    this.additionalServices = const {},
  });

  int get totalDays => endDate.difference(startDate).inDays;
  bool get isActive => status == 'active' || status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'createdAt': createdAt.toIso8601String(),
      'additionalServices': additionalServices,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      carId: json['carId'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
      pickupLocation: json['pickupLocation'],
      dropoffLocation: json['dropoffLocation'],
      createdAt: DateTime.parse(json['createdAt']),
      additionalServices: Map<String, dynamic>.from(
        json['additionalServices'] ?? {},
      ),
    );
  }
}

class Review {
  final String id;
  final String carId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;
  final bool isVerified;

  Review({
    required this.id,
    required this.carId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      carId: json['carId'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      photos: List<String>.from(json['photos'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      isVerified: json['isVerified'] ?? false,
    );
  }
}
