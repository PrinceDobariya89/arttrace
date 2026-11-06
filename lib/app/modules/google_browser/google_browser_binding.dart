import 'package:get/get.dart';
import 'google_browser_controller.dart';

class GoogleBrowserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GoogleBrowserController>(() => GoogleBrowserController());
  }
}

