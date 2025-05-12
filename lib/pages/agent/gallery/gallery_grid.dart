import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'gallery_service.dart';
import 'gallery_image_item.dart';

class GalleryGrid extends StatelessWidget {
  const GalleryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final galleryService = Get.find<GalleryService>();
    // 根据屏幕宽度决定列数
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 5 : 2; // 宽屏使用3列，窄屏使用2列

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() => MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10, // 增加垂直间距
        crossAxisSpacing: 10, // 增加水平间距
        itemCount: galleryService.filteredImages.length,
        // 添加物理滚动效果
        physics: const BouncingScrollPhysics(),
        // 设置砖砌布局参数
        itemBuilder: (context, index) {
          final image = galleryService.filteredImages[index];
          
          // 使用IndexedSemanticsTag确保Hero动画正常工作
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: GalleryImageItem(
              key: ValueKey('gallery_item_${image.id}'),
              image: image,
            ),
          );
        },
      )),
    );
  }
} 