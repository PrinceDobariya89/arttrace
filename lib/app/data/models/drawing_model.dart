enum DrawingDifficulty { beginner, intermediate, advanced }

class DrawingModel {
  final String id;
  final String title;
  final String categoryId;
  final String categoryName;
  final String assetPath;
  final bool isLocalFile;
  final bool isPremium;
  final DrawingDifficulty difficulty;
  final List<String> tags;
  final int stepsCount;
  final int estimatedMinutes;
  final bool hasTutorial;
  final double aspectRatio;
  final double rating;
  final int viewsCount;
  final String? description;

  const DrawingModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.assetPath,
    this.isLocalFile = false,
    this.isPremium = false,
    this.difficulty = DrawingDifficulty.beginner,
    this.tags = const [],
    this.stepsCount = 4,
    this.estimatedMinutes = 15,
    this.hasTutorial = false,
    this.aspectRatio = 1.0,
    this.rating = 4.8,
    this.viewsCount = 120,
    this.description,
  });

  String get difficultyLabel {
    switch (difficulty) {
      case DrawingDifficulty.beginner:
        return 'Beginner';
      case DrawingDifficulty.intermediate:
        return 'Intermediate';
      case DrawingDifficulty.advanced:
        return 'Advanced';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'assetPath': assetPath,
    'isLocalFile': isLocalFile,
    'isPremium': isPremium,
    'difficulty': difficulty.index,
    'tags': tags,
    'stepsCount': stepsCount,
    'estimatedMinutes': estimatedMinutes,
    'hasTutorial': hasTutorial,
    'aspectRatio': aspectRatio,
    'rating': rating,
    'viewsCount': viewsCount,
    'description': description,
  };

  factory DrawingModel.fromJson(Map<String, dynamic> json) {
    return DrawingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      assetPath: json['assetPath'] as String,
      isLocalFile: json['isLocalFile'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      difficulty: DrawingDifficulty.values[json['difficulty'] as int? ?? 0],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      stepsCount: json['stepsCount'] as int? ?? 4,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
      hasTutorial: json['hasTutorial'] as bool? ?? false,
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 1.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      viewsCount: json['viewsCount'] as int? ?? 120,
      description: json['description'] as String?,
    );
  }
}

