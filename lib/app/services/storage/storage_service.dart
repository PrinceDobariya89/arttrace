import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../common/utils/constants.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  final RxBool isFirstLaunch = true.obs;
  final RxBool isPremium = false.obs;
  final RxSet<String> favorites = <String>{}.obs;
  final RxList<String> recentDrawings = <String>[].obs;
  final RxString themeMode = 'system'.obs;
  final RxBool hapticFeedback = true.obs;
  final RxDouble defaultOpacity = 0.65.obs;
  final RxBool showStandGuide = true.obs;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();

    isFirstLaunch.value = _box.read<bool>(AppConstants.keyIsFirstLaunch) ?? true;
    isPremium.value = _box.read<bool>(AppConstants.keyIsPremium) ?? false;
    
    final List<dynamic>? favList = _box.read<List<dynamic>>(AppConstants.keyFavorites);
    if (favList != null) {
      favorites.addAll(favList.cast<String>());
    }

    final List<dynamic>? recList = _box.read<List<dynamic>>(AppConstants.keyRecentDrawings);
    if (recList != null) {
      recentDrawings.addAll(recList.cast<String>());
    }

    themeMode.value = _box.read<String>(AppConstants.keyThemeMode) ?? 'system';
    hapticFeedback.value = _box.read<bool>(AppConstants.keyHapticFeedback) ?? true;
    defaultOpacity.value = _box.read<double>(AppConstants.keyDefaultOpacity) ?? 0.65;
    showStandGuide.value = _box.read<bool>(AppConstants.keyShowStandGuide) ?? true;

    return this;
  }

  void completeOnboarding() {
    isFirstLaunch.value = false;
    _box.write(AppConstants.keyIsFirstLaunch, false);
  }

  void setPremium(bool value) {
    isPremium.value = value;
    _box.write(AppConstants.keyIsPremium, value);
  }

  bool isFavorite(String drawingId) {
    return favorites.contains(drawingId);
  }

  void toggleFavorite(String drawingId) {
    if (favorites.contains(drawingId)) {
      favorites.remove(drawingId);
    } else {
      favorites.add(drawingId);
    }
    _box.write(AppConstants.keyFavorites, favorites.toList());
  }

  void addRecentDrawing(String drawingId) {
    recentDrawings.remove(drawingId);
    recentDrawings.insert(0, drawingId);
    if (recentDrawings.length > 20) {
      recentDrawings.removeLast();
    }
    _box.write(AppConstants.keyRecentDrawings, recentDrawings.toList());
  }

  void setThemeMode(String mode) {
    themeMode.value = mode;
    _box.write(AppConstants.keyThemeMode, mode);
  }

  void setHapticFeedback(bool enabled) {
    hapticFeedback.value = enabled;
    _box.write(AppConstants.keyHapticFeedback, enabled);
  }

  void setDefaultOpacity(double val) {
    defaultOpacity.value = val;
    _box.write(AppConstants.keyDefaultOpacity, val);
  }

  void setShowStandGuide(bool show) {
    showStandGuide.value = show;
    _box.write(AppConstants.keyShowStandGuide, show);
  }

  List<Map<String, dynamic>> getSavedArtworksRaw() {
    final List<dynamic>? list = _box.read<List<dynamic>>(AppConstants.keySavedArtworks);
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  void saveArtworkRaw(Map<String, dynamic> raw) {
    final list = getSavedArtworksRaw();
    list.insert(0, raw);
    _box.write(AppConstants.keySavedArtworks, list);
  }

  void deleteArtworkRaw(String id) {
    final list = getSavedArtworksRaw();
    list.removeWhere((item) => item['id'] == id);
    _box.write(AppConstants.keySavedArtworks, list);
  }
}

