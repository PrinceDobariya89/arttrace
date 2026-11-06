import 'package:get/get.dart';
import '../modules/gallery/gallery_binding.dart';
import '../modules/gallery/gallery_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/google_browser/google_browser_binding.dart';
import '../modules/google_browser/google_browser_view.dart';
import '../modules/image_detail/image_detail_binding.dart';
import '../modules/image_detail/image_detail_view.dart';
import '../modules/main_nav/main_nav_binding.dart';
import '../modules/main_nav/main_nav_view.dart';
import '../modules/my_art/my_art_binding.dart';
import '../modules/my_art/my_art_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/premium/premium_binding.dart';
import '../modules/premium/premium_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/tracing/tracing_binding.dart';
import '../modules/tracing/tracing_view.dart';
import '../modules/tutorials/tutorial_detail_view.dart';
import '../modules/tutorials/tutorials_binding.dart';
import '../modules/web_explorer/web_explorer_binding.dart';
import '../modules/web_explorer/web_explorer_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.mainNav,
      page: () => const MainNavView(),
      binding: MainNavBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.gallery,
      page: () => const GalleryView(),
      binding: GalleryBinding(),
    ),
    GetPage(
      name: Routes.imageDetail,
      page: () => const ImageDetailView(),
      binding: ImageDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.tracing,
      page: () => const TracingView(),
      binding: TracingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.tutorialDetail,
      page: () => const TutorialDetailView(),
      binding: TutorialsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.myArt,
      page: () => const MyArtView(),
      binding: MyArtBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.premium,
      page: () => const PremiumView(),
      binding: PremiumBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.webExplorer,
      page: () => const WebExplorerView(),
      binding: WebExplorerBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.googleBrowser,
      page: () => const GoogleImageBrowserView(),
      binding: GoogleBrowserBinding(),
      transition: Transition.cupertino,
    ),
  ];
}

