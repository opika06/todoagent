import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/gallery_service.dart';
import '../widgets/gallery_grid.dart';
import '../widgets/dialog_confirm.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化GalleryService
    final galleryService = Get.find<GalleryService>();

    return Column(
      children: [
        AppBar(
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
        ),
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
