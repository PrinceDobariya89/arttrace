import 'package:get/get.dart';
import '../../common/utils/helpers.dart';
import '../my_art/my_art_controller.dart';

class MainNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    if (currentIndex.value != index) {
      AppHelpers.hapticLight();
      currentIndex.value = index;
      if (index == 2 && Get.isRegistered<MyArtController>()) {
        Get.find<MyArtController>().loadData();
      }
    }
  }
}

