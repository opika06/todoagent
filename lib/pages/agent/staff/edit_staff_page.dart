import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'staff_service.dart';
import '../../../models/staff_model.dart';
import '../../../widgets/dialog_confirm.dart';

class EditStaffPage extends StatelessWidget {
  final Staff? staff;
  final bool isEditing;

  EditStaffPage({super.key, this.staff}) : isEditing = staff != null;

  late final nameController = TextEditingController(text: staff?.name ?? '');
  late final detailController = TextEditingController(text: staff?.detail ?? '');
  final tagController = TextEditingController();
  late final RxList<String> tags = RxList<String>(staff?.tags.toList() ?? []);
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑干员档案' : '新建干员档案'),
        actions: [
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final StaffService staffService = Get.find<StaffService>();
                
                if (isEditing && staff != null) {
                  // 更新现有干员
                  staffService.updateStaff(
                    staff!.id,
                    nameController.text.trim(),
                    detailController.text.trim(),
                    tags.toList(),
                  );
                } else {
                  // 添加新干员
                  staffService.addStaff(
                    nameController.text.trim(),
                    detailController.text.trim(),
                    tags.toList(),
                  );
                }
                Get.back();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 16),
              
              // 干员详情
              TextFormField(
                controller: detailController,
                decoration: const InputDecoration(
                  labelText: '干员详情',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: '请输入干员的详细描述（选填）',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              
              // 标签标题
              const Text(
                '特性标签',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
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
              const SizedBox(height: 16),
              Obx(() {
                if (tags.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        '尚未添加标签',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => tags.remove(tag),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                  );
                }
              }),
              
              // 删除按钮 (仅在编辑模式下显示)
              if (isEditing) ...[
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 2.0),
                    ),
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      elevation: 0,
                      child: InkWell(
                        onTap: () {
                          DialogConfirm.show(
                            title: '删除干员',
                            content: '确定要删除${staff?.name}的档案吗？',
                            onConfirm: () async {
                              if (staff != null) {
                                await Get.find<StaffService>().deleteStaff(staff!.id);
                              }
                              Get.back();
                            },
                          );
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 