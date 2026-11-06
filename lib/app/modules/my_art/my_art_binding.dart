import 'package:get/get.dart';
import 'my_art_controller.dart';

class MyArtBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyArtController>(() => MyArtController());
  }
}

