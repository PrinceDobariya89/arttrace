import 'package:get/get.dart';
import 'tutorials_controller.dart';

class TutorialsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TutorialsController>(() => TutorialsController());
  }
}

