import 'package:get/get.dart';
import '../pages/gallery_page.dart';
import '../pages/demo_page.dart';
import '../pages/main_page.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.MAIN;

  static final routes = [
    GetPage(
      name: Routes.MAIN,
      page: () => const MainPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.GALLERY,
      page: () => const GalleryPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.DEMO,
      page: () => const DemoPage(),
      transition: Transition.rightToLeft,
    ),
  ];
} 