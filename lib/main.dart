import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/agent/gallery/gallery_service.dart';
import 'services/storage_service.dart';
import 'pages/agent/staff/staff_service.dart';
import 'pages/agent/task/task_service.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服务
  await initServices();

  runApp(const MyApp());
}

// 初始化所有服务
Future<void> initServices() async {
  // 初始化存储服务
  await Get.putAsync<StorageService>(() async {
    final service = StorageService();
    return await service.init();
  });

  // 初始化图库服务
  Get.put(GalleryService());

  // 初始化干员服务
  await Get.putAsync<StaffService>(() async {
    final service = StaffService();
    return await service.init();
  });

  // 初始化任务服务
  await Get.putAsync<TaskService>(() async {
    final service = TaskService();
    return await service.init();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TodoAgent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
