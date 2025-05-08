import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryImage {
  final String id;
  final File file;
  final String name;
  final DateTime addedDate;
  final int size; // 文件大小（字节）
  final Rx<Size?> imageSize = Rx<Size?>(null); // 图片尺寸

  GalleryImage({
    required this.id,
    required this.file,
    required this.name,
    required this.addedDate,
    required this.size,
  }) {
    // 异步获取图片尺寸
    _loadImageSize();
  }

  // 获取图片路径
  String get path => file.path;

  // 获取文件扩展名
  String get extension => name.split('.').last;

  // 获取格式化的文件大小
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
  
  // 获取图片宽高比，默认为1.0
  double get aspectRatio {
    if (imageSize.value == null) return 1.0;
    return imageSize.value!.width / imageSize.value!.height;
  }

  // 异步加载图片尺寸
  Future<void> _loadImageSize() async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      imageSize.value = Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      debugPrint('获取图片尺寸失败: $e');
      // 设置一个默认尺寸，避免UI问题
      imageSize.value = const Size(100, 100);
    }
  }

  // 生成唯一ID
  static String _generateUniqueId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(100000);
    return '$timestamp-$randomPart';
  }

  // 从文件创建图片对象
  factory GalleryImage.fromFile(File file) {
    final name = file.path.split('/').last;
    return GalleryImage(
      id: _generateUniqueId(),
      file: file,
      name: name,
      addedDate: DateTime.now(),
      size: file.lengthSync(),
    );
  }
} 