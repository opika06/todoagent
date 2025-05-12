import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'staff_service.dart';
import '../../../models/staff_model.dart';
import '../../../widgets/dialog_confirm.dart';
import '../gallery/gallery_service.dart';
import '../gallery/gallery_page.dart';

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
  late final RxList<String> imageIds = RxList<String>(
    staff?.imageIds.toList() ?? [],
  );
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? '编辑' : '新建',
          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
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
                    imageIds.toList(),
                  );
                } else {
                  // 添加新干员
                  staffService.addStaff(
                    nameController.text.trim(),
                    detailController.text.trim(),
                    tags.toList(),
                    imageIds.toList(),
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
                        labelText: '🥷 干员名称',
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
                        child: Obx(
                          () => LikeButton(
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
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                                size: 24,
                              );
                            },
                            onTap: (isLiked) async {
                              // 切换收藏状态
                              Get.find<StaffService>().toggleStaffLike(
                                staff!.id,
                              );
                              // 返回新的状态
                              return !isLiked;
                            },
                          ),
                        ),
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

              // Text(
              //   "Tags",
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              // ),

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

              const SizedBox(height: 24),

              // 图片区域标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "图片",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // 添加图片按钮
                  ElevatedButton.icon(
                    onPressed: () async {
                      // 进入图库选择模式
                      final galleryService = Get.find<GalleryService>();
                      galleryService.isSelectMode.value = true;
                      galleryService.selectedImageIds.clear();

                      // 预先选中已有的图片
                      if (imageIds.isNotEmpty) {
                        for (final id in imageIds) {
                          galleryService.selectedImageIds.add(id);
                        }
                      }

                      // 跳转到图库页面
                      final result = await Get.to(
                        () => Scaffold(
                          body: const GalleryPage(),
                          bottomNavigationBar: BottomAppBar(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      galleryService.clearSelection();
                                      Get.back(result: null);
                                    },
                                    child: const Text('取消'),
                                  ),
                                  Obx(
                                    () => Text(
                                      '已选择 ${galleryService.selectedImageIds.length} 项',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back(
                                        result:
                                            galleryService.selectedImageIds
                                                .toList(),
                                      );
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      // 处理返回结果
                      if (result != null && result is List<String>) {
                        imageIds.clear();
                        imageIds.addAll(result);
                      }
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('选择图片'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 显示已选图片
              Obx(() {
                if (imageIds.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        '尚未添加图片',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  );
                } else {
                  // 创建一个与GalleryGrid相似的布局来显示已选图片
                  return SizedBox(
                    height: 300,
                    child: Builder(
                      builder: (context) {
                        final galleryService = Get.find<GalleryService>();
                        final selectedImages =
                            galleryService.images
                                .where((img) => imageIds.contains(img.id))
                                .toList();

                        // 根据屏幕宽度决定列数
                        final screenWidth = MediaQuery.of(context).size.width;
                        final crossAxisCount = screenWidth > 600 ? 4 : 2;

                        return MasonryGridView.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          itemCount: selectedImages.length,
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final image = selectedImages[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Stack(
                                children: [
                                  Card(
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AspectRatio(
                                          aspectRatio:
                                              image.imageSize.value != null
                                                  ? image.aspectRatio
                                                  : 1.0,
                                          child: Image.file(
                                            image.file,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          imageIds.remove(image.id);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
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
