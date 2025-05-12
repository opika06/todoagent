import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'staff_service.dart';
import 'staff_card.dart';
import '../../../routes/app_pages.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取StaffController实例
    final controller = Get.put(StaffController());

    return Column(
      children: [
        AppBar(
          title: const Text(
            '档案',
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // 新建"干员档案"
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => Get.toNamed(Routes.STAFF_EDIT),
            ),
          ],
        ),
        Expanded(
          child: Obx(() {
            final staffList = controller.staffService.staffList;

            if (staffList.isEmpty) {
              // 空状态显示
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_rounded),
                      iconSize: 80,
                      color: Colors.blueAccent,
                      onPressed: () => Get.toNamed(Routes.STAFF_EDIT),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '暂无档案',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '点击上方 "+" 按钮添加',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else {
              // 显示干员网格
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StaffCard(staff: staffList[index]),
                  );
                },
              );
            }
          }),
        ),
      ],
    );
  }
}

class StaffController extends GetxController {
  late final StaffService staffService;

  @override
  void onInit() {
    super.onInit();
    staffService = Get.find<StaffService>();
  }
}
