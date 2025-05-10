import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'staff_service.dart';
import '../../../models/staff_model.dart';
import '../../../widgets/dialog_confirm.dart';

class EditStaffPage extends StatelessWidget {
  final Staff? staff;
  final bool isEditing;

  EditStaffPage({super.key, this.staff}) : isEditing = staff != null;

  late final nameController = TextEditingController(text: staff?.name ?? '');
  late final detailController = TextEditingController(
    text: staff?.detail ?? '',
  );
  final tagController = TextEditingController();
  late final RxList<String> tags = RxList<String>(staff?.tags.toList() ?? []);
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑' : '新建'),
        actions: [
          // 保存按钮
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: '保存',
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
          ),
          // 删除按钮 (仅在编辑模式下显示)
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.grey),
              tooltip: '删除',
              onPressed: () {
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '🥷 名称',
                        hintText: "必填",
                        border: OutlineInputBorder(),
                        // prefixIcon: Icon(Icons.person_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入干员名称';
                        }
                        return null;
                      },
                    ),
                  ),
                  // 收藏按钮，仅编辑模式显示
                  if (isEditing && staff != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: Obx(() => LikeButton(
                          size: 32,
                          isLiked: staff!.isLike.value,
                          circleColor: const CircleColor(
                            start: Color(0xFFFF5722),
                            end: Color(0xFFFFC107),
                          ),
                          bubblesColor: const BubblesColor(
                            dotPrimaryColor: Color(0xFFFF5722),
                            dotSecondaryColor: Color(0xFFFFC107),
                          ),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 24,
                            );
                          },
                          onTap: (isLiked) async {
                            // 切换收藏状态
                            Get.find<StaffService>().toggleStaffLike(staff!.id);
                            // 返回新的状态
                            return !isLiked;
                          },
                        )),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // 干员详情
              TextFormField(
                controller: detailController,
                decoration: const InputDecoration(
                  labelText: '📃 详情',
                  hintText: '选填',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  // prefixIcon: Icon(Icons.description_rounded),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              Text(
                "Tags",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              // 显示已添加的标签
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      // color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          tags.map((tag) {
                            final tagKey = GlobalKey<State>();
                            final RxBool isLongPressed = false.obs;

                            return Obx(
                              () => GestureDetector(
                                key: tagKey,
                                onLongPress: () {
                                  isLongPressed.value = true;
                                },
                                onLongPressEnd: (_) {
                                  // 长按结束后延迟一会再隐藏删除图标
                                  Future.delayed(
                                    const Duration(seconds: 3),
                                    () {
                                      isLongPressed.value = false;
                                    },
                                  );
                                },
                                child: Chip(
                                  label: Text(tag),
                                  labelStyle: const TextStyle(fontSize: 12),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted:
                                      isLongPressed.value
                                          ? () => tags.remove(tag)
                                          : null,
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  );
                }
              }),

              // 标签添加区域
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: tagController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: '🔖 添加 Tag',
                        hintStyle: TextStyle(fontSize: 14),
                        border: UnderlineInputBorder(),
                        contentPadding: EdgeInsets.only(bottom: 10),
                        isDense: true,
                      ),
                      onFieldSubmitted: (value) {
                        final tag = value.trim();
                        if (tag.isNotEmpty && !tags.contains(tag)) {
                          tags.add(tag);
                          tagController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
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
            ],
          ),
        ),
      ),
    );
  }
}
