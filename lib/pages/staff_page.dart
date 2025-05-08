import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';
import '../widgets/staff_card.dart';
import '../widgets/dialog_add_staff.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取StaffController实例
    final controller = Get.put(StaffController());

    return Column(
      children: [
        AppBar(
          title: const Text('干员档案'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => DialogAddStaff.show(),
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
                    const Icon(Icons.person_rounded, size: 80, color: Colors.blue),
                    const SizedBox(height: 20),
                    const Text(
                      '干员档案管理',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '尚未添加任何干员档案',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => DialogAddStaff.show(),
                      icon: const Icon(Icons.add),
                      label: const Text('添加干员'),
                    ),
                  ],
                ),
              );
            } else {
              // 显示干员网格
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 每行显示3个
                  childAspectRatio: 0.8, // 宽高比
                  crossAxisSpacing: 12, // 水平间距
                  mainAxisSpacing: 12, // 垂直间距
                ),
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  return StaffCard(staff: staffList[index]);
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
