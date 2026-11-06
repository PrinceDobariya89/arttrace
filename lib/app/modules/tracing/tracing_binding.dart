import 'package:get/get.dart';
import 'tracing_controller.dart';

class TracingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TracingController>(() => TracingController());
  }
}

