import 'package:get/get.dart';

class Staff {
  final String id;
  final String name;
  final String detail;
  final RxList<String> tags;
  final RxBool isLike;
  final RxList<String> imageIds;

  Staff({
    required this.id,
    required this.name,
    required this.detail,
    required List<String> tags,
    bool isLike = false,
    List<String>? imageIds,

  }) : tags = tags.obs, 
       isLike = isLike.obs,
       imageIds = (imageIds ?? []).obs;

  // 从Map创建Staff对象
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] as String,
      name: json['name'] as String, 
      detail: json['detail'] as String,
      tags: List<String>.from(json['tags']),
      isLike: json['isLike'] as bool? ?? false,
      imageIds: List<String>.from(json['imageIds'] ?? []),
    );
  }

  // 转换为Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'detail': detail,
      'tags': tags.toList(),
      'isLike': isLike.value,
      'imageIds': imageIds.toList(),
    };
  }
} 