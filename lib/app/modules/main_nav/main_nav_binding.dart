import 'package:get/get.dart';
import '../gallery/gallery_controller.dart';
import '../home/home_controller.dart';
import '../my_art/my_art_controller.dart';
import '../settings/settings_controller.dart';
import 'main_nav_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavController>(() => MainNavController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<GalleryController>(() => GalleryController());
    Get.lazyPut<MyArtController>(() => MyArtController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}

