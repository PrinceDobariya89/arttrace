import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/common/utils/constants.dart';
import 'app/routes/app_pages.dart';
import 'app/services/ads/ad_service.dart';
import 'app/services/camera/camera_service.dart';
import 'app/services/purchases/purchase_service.dart';
import 'app/services/storage/storage_service.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI and orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Storage Service first
  final storageService = await StorageService().init();
  Get.put<StorageService>(storageService);

  // Initialize Core Services
  final cameraService = await CameraService().init();
  Get.put<CameraService>(cameraService);

  final adService = await AdService(storageService).init();
  Get.put<AdService>(adService);

  final purchaseService = await PurchaseService(storageService).init();
  Get.put<PurchaseService>(purchaseService);

  runApp(const ArtTraceApp());
}

class ArtTraceApp extends StatelessWidget {
  const ArtTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();

    ThemeMode initialThemeMode = ThemeMode.system;
    if (storageService.themeMode.value == 'light') {
      initialThemeMode = ThemeMode.light;
    } else if (storageService.themeMode.value == 'dark') {
      initialThemeMode = ThemeMode.dark;
    }

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}
