import 'package:flutter/material.dart';
import '../models/category_model.dart';

class SampleCategories {
  static const List<CategoryModel> categories = [
    CategoryModel(
      id: 'anime',
      title: 'Anime',
      description: 'Manga characters, expressions, eyes, and action poses',
      icon: Icons.face_retouching_natural_rounded,
      drawingCount: 24,
    ),
    CategoryModel(
      id: 'cartoon',
      title: 'Cartoon',
      description: 'Animated figures, whimsical creatures, and fun comics',
      icon: Icons.animation_rounded,
      drawingCount: 18,
    ),
    CategoryModel(
      id: 'animals',
      title: 'Animals',
      description: 'Lions, horses, birds, and wildlife sketches',
      icon: Icons.pets_rounded,
      drawingCount: 30,
    ),
    CategoryModel(
      id: 'flowers',
      title: 'Flowers',
      description: 'Roses, lotus, botanical vines, and blossom bouquets',
      icon: Icons.local_florist_rounded,
      drawingCount: 22,
    ),
    CategoryModel(
      id: 'nature',
      title: 'Nature',
      description: 'Mountains, forests, sea waves, and outdoor sceneries',
      icon: Icons.landscape_rounded,
      drawingCount: 16,
    ),
    CategoryModel(
      id: 'vehicles',
      title: 'Vehicles',
      description: 'Sports cars, vintage motorbikes, planes, and trucks',
      icon: Icons.directions_car_rounded,
      drawingCount: 15,
    ),
    CategoryModel(
      id: 'superheroes',
      title: 'Superheroes',
      description: 'Masks, logos, shields, and heroic silhouettes',
      icon: Icons.shield_rounded,
      drawingCount: 12,
    ),
    CategoryModel(
      id: 'cute',
      title: 'Cute Characters',
      description: 'Kawaii boba, chibi plushies, and happy doodles',
      icon: Icons.favorite_rounded,
      drawingCount: 28,
    ),
    CategoryModel(
      id: 'beginner',
      title: 'Beginner Drawing',
      description: 'Simple geometric shapes, everyday cups, and icons',
      icon: Icons.school_rounded,
      drawingCount: 20,
    ),
    CategoryModel(
      id: 'advanced',
      title: 'Advanced Drawing',
      description: 'Realistic eyes, anatomical studies, and cybernetic art',
      icon: Icons.auto_awesome_rounded,
      drawingCount: 14,
    ),
  ];
}

