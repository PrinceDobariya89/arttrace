class ArtworkModel {
  final String id;
  final String title;
  final String filePath;
  final String? originalDrawingId;
  final String category;
  final DateTime createdAt;
  final String? notes;

  const ArtworkModel({
    required this.id,
    required this.title,
    required this.filePath,
    this.originalDrawingId,
    this.category = 'Traced Art',
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'filePath': filePath,
    'originalDrawingId': originalDrawingId,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'notes': notes,
  };

  factory ArtworkModel.fromJson(Map<String, dynamic> json) {
    return ArtworkModel(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      originalDrawingId: json['originalDrawingId'] as String?,
      category: json['category'] as String? ?? 'Traced Art',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String?,
    );
  }
}

