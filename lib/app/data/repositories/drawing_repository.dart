import '../models/drawing_model.dart';
import '../sample_data/sample_drawings.dart';
import '../../services/storage/storage_service.dart';

class DrawingRepository {
  final StorageService _storageService;
  DrawingRepository(this._storageService);

  List<DrawingModel> getAllDrawings() {
    return List.from(SampleDrawings.drawings);
  }

  List<DrawingModel> getDrawingsByCategory(String categoryId) {
    return SampleDrawings.drawings
        .where((d) => d.categoryId.toLowerCase() == categoryId.toLowerCase())
        .toList();
  }

  List<DrawingModel> getFeaturedDrawings() {
    return [
      SampleDrawings.drawings[1], // Sparkling Anime Eye
      SampleDrawings.drawings[5], // Velvet Rose
      SampleDrawings.drawings[0], // Anime Boy
      SampleDrawings.drawings[7], // Aero GT Sports Car
      SampleDrawings.drawings[9], // Kawaii Boba
    ];
  }

  List<DrawingModel> getTrendingDrawings() {
    final list = List<DrawingModel>.from(SampleDrawings.drawings);
    list.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    return list.take(6).toList();
  }

  List<DrawingModel> getPremiumDrawings() {
    return SampleDrawings.drawings.where((d) => d.isPremium).toList();
  }

  List<DrawingModel> getBeginnerDrawings() {
    return SampleDrawings.drawings
        .where((d) => d.difficulty == DrawingDifficulty.beginner)
        .toList();
  }

  List<DrawingModel> searchDrawings(String query) {
    if (query.trim().isEmpty) return getAllDrawings();
    final q = query.toLowerCase().trim();
    return SampleDrawings.drawings.where((d) {
      final inTitle = d.title.toLowerCase().contains(q);
      final inCat = d.categoryName.toLowerCase().contains(q);
      final inTags = d.tags.any((t) => t.toLowerCase().contains(q));
      return inTitle || inCat || inTags;
    }).toList();
  }

  DrawingModel? getDrawingById(String id) {
    try {
      return SampleDrawings.drawings.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  List<DrawingModel> getFavorites() {
    final favIds = _storageService.favorites;
    return SampleDrawings.drawings.where((d) => favIds.contains(d.id)).toList();
  }

  List<DrawingModel> getRecentlyViewed() {
    final recentIds = _storageService.recentDrawings;
    final List<DrawingModel> result = [];
    for (final id in recentIds) {
      final drawing = getDrawingById(id);
      if (drawing != null) {
        result.add(drawing);
      }
    }
    return result;
  }
}

