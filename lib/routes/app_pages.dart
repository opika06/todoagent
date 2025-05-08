import 'package:get/get.dart';
import '../pages/gallery_page.dart';
import '../pages/demo_page.dart';
import '../pages/main_page.dart';
import '../pages/staff_page.dart';
import '../pages/staff_detail_page.dart';

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
    GetPage(
      name: Routes.STAFF,
      page: () => const StaffPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.STAFF_DETAIL,
      page: () => StaffDetailPage(staff: Get.arguments),
      transition: Transition.rightToLeft,
    ),
  ];
} 