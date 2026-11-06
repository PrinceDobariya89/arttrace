import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String? bannerAsset;
  final int drawingCount;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.bannerAsset,
    this.drawingCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'drawingCount': drawingCount,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json, IconData fallbackIcon) {
    return CategoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: fallbackIcon,
      drawingCount: json['drawingCount'] as int? ?? 0,
    );
  }
}

