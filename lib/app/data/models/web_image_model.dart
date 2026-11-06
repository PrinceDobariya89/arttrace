class WebImageModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? thumbnailUrl;
  final String category;
  final String source;
  final List<String> tags;
  final double aspectRatio;

  const WebImageModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.category,
    this.source = 'Web',
    this.tags = const [],
    this.aspectRatio = 1.0,
  });

  String get displayThumbnail => thumbnailUrl ?? imageUrl;
}

