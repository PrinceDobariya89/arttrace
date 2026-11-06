import 'dart:io';
import '../models/artwork_model.dart';
import '../../services/storage/storage_service.dart';

class ArtworkRepository {
  final StorageService _storageService;
  ArtworkRepository(this._storageService);

  List<ArtworkModel> getAllArtworks() {
    final rawList = _storageService.getSavedArtworksRaw();
    return rawList.map((e) => ArtworkModel.fromJson(e)).toList();
  }

  void saveArtwork(ArtworkModel artwork) {
    _storageService.saveArtworkRaw(artwork.toJson());
  }

  void deleteArtwork(String id) {
    final list = getAllArtworks();
    final toDelete = list.where((a) => a.id == id).toList();
    for (final item in toDelete) {
      try {
        final f = File(item.filePath);
        if (f.existsSync()) {
          f.deleteSync();
        }
      } catch (_) {}
    }
    _storageService.deleteArtworkRaw(id);
  }
}

