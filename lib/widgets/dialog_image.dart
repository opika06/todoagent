import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import '../models/gallery_image.dart';
import '../pages/agent/gallery/gallery_service.dart';

class DialogImage {
  static void show(GalleryImage image) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片内容
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Stack(
                  children: [
                    // 可交互图片
                    InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        child: Image.file(
                          image.file,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    // 喜欢按钮
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: Obx(() => LikeButton(
                          size: 40,
                          isLiked: image.isLike.value,
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
                              color: isLiked ? Colors.red : Colors.white,
                              size: 28,
                            );
                          },
                          onTap: (isLiked) async {
                            // 切换喜欢状态
                            Get.find<GalleryService>().toggleImageLike(image.id);
                            // 返回新的状态
                            return !isLiked;
                          },
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
