import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/gallery_image.dart';
import 'gallery_service.dart';
import '../../../widgets/dialog_image.dart';

class GalleryImageItem extends StatelessWidget {
  final GalleryImage image;

  const GalleryImageItem({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final galleryService = Get.find<GalleryService>();

    return Obx(() {
      final isSelected = galleryService.selectedImageIds.contains(image.id);
      final isSelectMode = galleryService.isSelectMode.value;
      final isLiked = image.isLike.value;

      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            if (isSelectMode) {
              // 如果是选择模式，切换选中状态
              galleryService.toggleImageSelection(image.id);
            } else {
              // 否则，显示图片对话框
              DialogImage.show(image);
            }
          },
          onLongPress: () {
            // 长按进入选择模式并选中当前图片
            if (!isSelectMode) {
              galleryService.toggleImageSelection(image.id);
            }
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图片区域 - 根据图片实际宽高比显示
                  Obx(() {
                    // 使用Obx监听图片尺寸变化
                    if (image.imageSize.value != null) {
                      return Hero(
                        tag: 'image_${image.id}',
                        child: AspectRatio(
                          aspectRatio: image.aspectRatio,
                          child: Image.file(
                            image.file,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            frameBuilder: (
                              BuildContext context,
                              Widget child,
                              int? frame,
                              bool wasSynchronouslyLoaded,
                            ) {
                              if (wasSynchronouslyLoaded) {
                                return child;
                              }
                              return AnimatedOpacity(
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                child: child,
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      // 图片尺寸未加载完成时，显示加载中的占位图
                      return AspectRatio(
                        aspectRatio: 1.0, // 默认1:1比例
                        child: Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                  }),
                ],
              ),

              // 选中状态指示器
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),

              // 喜欢状态指示器
              if (isLiked && !isSelectMode)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    // decoration: const BoxDecoration(
                    //   color: Colors.black54,
                    //   shape: BoxShape.circle,
                    // ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
