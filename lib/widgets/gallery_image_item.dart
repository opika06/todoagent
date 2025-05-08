import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/gallery_image.dart';
import 'dialog_image.dart';

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
