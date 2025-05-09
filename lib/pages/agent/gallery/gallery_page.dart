import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gallery_service.dart';
import 'gallery_grid.dart';
import '../../../widgets/dialog_confirm.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化GalleryService
    final galleryService = Get.find<GalleryService>();

    return Column(
      children: [
        Obx(() {
          // 根据是否处于选择模式显示不同的AppBar
          if (galleryService.isSelectMode.value) {
            return AppBar(
              title: Obx(() => Text('已选择 ${galleryService.selectedImageIds.length} 项')),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => galleryService.clearSelection(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () => galleryService.selectAll(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    if (galleryService.selectedImageIds.isNotEmpty) {
                      DialogConfirm.show(
                        title: '删除选中项',
                        content: '确定要删除选中的 ${galleryService.selectedImageIds.length} 张图片吗？',
                        onConfirm: () => galleryService.deleteSelected(),
                      );
                    }
                  },
                ),
              ],
            );
          } else {
            // 正常模式的AppBar
            return AppBar(
              title: const Text('本地图库'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => galleryService.pickImage(),
                ),
                Obx(
                  () => IconButton(
                    icon: const Icon(Icons.shuffle),
                    onPressed:
                        galleryService.images.isEmpty
                            ? null
                            : () => galleryService.showRandomImage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    if (galleryService.images.isNotEmpty) {
                      DialogConfirm.show(
                        title: '删除所有图片',
                        content: '确定要清空所有图片吗？',
                        onConfirm: () => galleryService.clearAll(),
                      );
                    }
                  },
                ),
              ],
            );
          }
        }),
        Expanded(
          child: Obx(() {
            if (galleryService.images.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.dashboard_customize),
                      iconSize: 80,
                      color: Colors.blue,
                      onPressed: () => galleryService.pickImage(),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '暂无图片',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '请点击上方 "+" 按钮添加',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else {
              return const GalleryGrid();
            }
          }),
        ),
      ],
    );
  }
}
