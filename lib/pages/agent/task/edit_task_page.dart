import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/task_model.dart';
import '../../../widgets/dialog_confirm.dart';
import 'task_service.dart';
import '../staff/staff_service.dart';

class EditTaskPage extends StatelessWidget {
  final Task? task;
  final bool isEditing;

  EditTaskPage({super.key, Task? taskParam})
    : task = taskParam ?? (Get.arguments is Task ? Get.arguments : null),
      isEditing = taskParam != null || Get.arguments is Task;

  late final nameController = TextEditingController(text: task?.name ?? '');
  late final detailController = TextEditingController(text: task?.detail ?? '');
  late final Rx<String?> selectedStaffId = (task?.staffId).obs;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final staffService = Get.find<StaffService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? '编辑任务' : '新建任务',
          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 保存按钮
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: '保存',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final TaskService taskService = Get.find<TaskService>();

                if (isEditing && task != null) {
                  // 更新现有任务
                  taskService.updateTask(
                    task!.id,
                    nameController.text.trim(),
                    detailController.text.trim(),
                    selectedStaffId.value ?? '',
                  );
                } else {
                  // 添加新任务
                  taskService.addTask(
                    nameController.text.trim(),
                    detailController.text.trim(),
                    selectedStaffId.value ?? '',
                  );
                }
                Get.back();
              }
            },
          ),
          // 删除按钮 (仅在编辑模式下显示)
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.grey),
              tooltip: '删除',
              onPressed: () {
                DialogConfirm.show(
                  title: '删除任务',
                  content: '确定要删除任务「${task?.name}」吗？',
                  onConfirm: () async {
                    if (task != null) {
                      await Get.find<TaskService>().deleteTask(task!.id);
                    }
                    Get.back();
                  },
                );
              },
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
              // 任务名称
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '📝 任务名称',
                        hintText: "必填",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入任务名称';
                        }
                        return null;
                      },
                    ),
                  ),
                  // 完成状态复选框，仅编辑模式显示
                  if (isEditing && task != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: Obx(
                          () => Checkbox(
                            value: task!.isCompleted.value,
                            onChanged: (value) {
                              Get.find<TaskService>().toggleTaskCompleted(
                                task!.id,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // 任务详情
              TextFormField(
                controller: detailController,
                decoration: const InputDecoration(
                  labelText: '📃 详情',
                  hintText: '选填',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // 关联干员
              Text(
                "关联干员",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // 干员选择下拉框
              Obx(() {
                final staffList = staffService.staffList;

                if (staffList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '尚未添加任何干员，请先在干员档案中添加干员',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                } else {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '选择关联干员',
                      border: OutlineInputBorder(),
                    ),
                    value:
                        selectedStaffId.value?.isNotEmpty == true
                            ? selectedStaffId.value
                            : null,
                    hint: const Text('请选择关联干员'),
                    items:
                        staffList.map((staff) {
                          return DropdownMenuItem<String>(
                            value: staff.id,
                            child: Text(staff.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedStaffId.value = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请选择关联干员';
                      }
                      return null;
                    },
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
