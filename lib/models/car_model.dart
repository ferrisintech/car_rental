import 'package:flutter/material.dart';

class Car {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String imageUrl;
  final List<String> galleryImages;
  final double pricePerDay;
  final String category;
  final int year;
  final String fuelType;
  final String transmission;
  final int seats;
  final int doors;
  final String color;
  final double engineSize;
  final int mileage;
  final String description;
  final List<String> features;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.imageUrl,
    required this.galleryImages,
    required this.pricePerDay,
    required this.category,
    required this.year,
    required this.fuelType,
    required this.transmission,
    required this.seats,
    required this.doors,
    required this.color,
    required this.engineSize,
    required this.mileage,
    required this.description,
    required this.features,
    required this.rating,
    required this.reviewCount,
    this.isAvailable = true,
  });

  String get fullName => '$brand $model';
  String get displayPrice => '\$${pricePerDay.toStringAsFixed(0)}/day';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'imageUrl': imageUrl,
      'galleryImages': galleryImages,
      'pricePerDay': pricePerDay,
      'category': category,
      'year': year,
      'fuelType': fuelType,
      'transmission': transmission,
      'seats': seats,
      'doors': doors,
      'color': color,
      'engineSize': engineSize,
      'mileage': mileage,
      'description': description,
      'features': features,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      imageUrl: json['imageUrl'],
      galleryImages: List<String>.from(json['galleryImages']),
      pricePerDay: json['pricePerDay'].toDouble(),
      category: json['category'],
      year: json['year'],
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      seats: json['seats'],
      doors: json['doors'],
      color: json['color'],
      engineSize: json['engineSize'].toDouble(),
      mileage: json['mileage'],
      description: json['description'],
      features: List<String>.from(json['features']),
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

class CarCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const CarCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CarFilter {
  final String category;
  final double minPrice;
  final double maxPrice;
  final int minYear;
  final int maxYear;
  final String fuelType;
  final String transmission;
  final int minSeats;

  const CarFilter({
    this.category = '',
    this.minPrice = 0,
    this.maxPrice = 1000,
    this.minYear = 2000,
    this.maxYear = 2025,
    this.fuelType = '',
    this.transmission = '',
    this.minSeats = 2,
  });
}
