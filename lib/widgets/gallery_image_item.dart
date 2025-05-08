import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/gallery_image.dart';
import '../services/gallery_service.dart';
import 'dialog_image.dart';
import 'dialog_confirm.dart';

class GalleryImageItem extends StatelessWidget {
  final GalleryImage image;

  const GalleryImageItem({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          // 点击显示对话框，而不是跳转页面
          DialogImage.show(image);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域 - 根据图片实际宽高比显示
            Stack(
              children: [
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

                // 删除按钮
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        DialogConfirm.show(
                          title: '删除图片',
                          content: '确定要删除这张图片吗？',
                          onConfirm: () => Get.find<GalleryService>().deleteImage(image.id),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 图片信息
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         image.name,
            //         style: const TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 12,
            //         ),
            //         maxLines: 1,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //       const SizedBox(height: 2),
            //       Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Text(
            //             image.formattedSize,
            //             style: TextStyle(
            //               color: Colors.grey.shade600,
            //               fontSize: 10,
            //             ),
            //           ),
            //           Obx(() {
            //             if (image.imageSize.value != null) {
            //               return Text(
            //                 ' • ${image.imageSize.value!.width.toInt()}x${image.imageSize.value!.height.toInt()}',
            //                 style: TextStyle(
            //                   color: Colors.grey.shade600,
            //                   fontSize: 10,
            //                 ),
            //               );
            //             } else {
            //               return const SizedBox.shrink();
            //             }
            //           }),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
