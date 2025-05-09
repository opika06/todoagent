import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'staff_service.dart';

class DialogAddStaff {
  static void show() {
    final nameController = TextEditingController();
    final detailController = TextEditingController();
    final tagController = TextEditingController();
    final RxList<String> tags = <String>[].obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  const Center(
                    child: Text(
                      '添加干员档案',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 干员名称
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '干员名称',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入干员名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // 干员详情
                  TextFormField(
                    controller: detailController,
                    decoration: const InputDecoration(
                      labelText: '干员详情',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入干员详情';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // 标签添加区域
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: tagController,
                          decoration: const InputDecoration(
                            labelText: '添加标签',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.label),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final tag = tagController.text.trim();
                          if (tag.isNotEmpty && !tags.contains(tag)) {
                            tags.add(tag);
                            tagController.clear();
                          }
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  
                  // 显示已添加的标签
                  const SizedBox(height: 12),
                  Obx(() {
                    if (tags.isEmpty) {
                      return const Center(
                        child: Text(
                          '尚未添加标签',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      );
                    } else {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => tags.remove(tag),
                          );
                        }).toList(),
                      );
                    }
                  }),
                  
                  // 按钮区域
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final StaffService staffService = Get.find<StaffService>();
                            staffService.addStaff(
                              nameController.text.trim(),
                              detailController.text.trim(),
                              tags.toList(),
                            );
                            Get.back();
                          }
                        },
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 