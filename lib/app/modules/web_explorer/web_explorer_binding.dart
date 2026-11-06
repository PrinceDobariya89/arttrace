import 'package:get/get.dart';
import 'web_explorer_controller.dart';

class WebExplorerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebExplorerController>(() => WebExplorerController());
  }
}

