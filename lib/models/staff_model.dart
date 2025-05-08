import 'package:get/get.dart';

class Staff {
  final String id;
  final String name;
  final String detail;
  final RxList<String> tags;

  Staff({
    required this.id,
    required this.name,
    required this.detail,
    required List<String> tags,
  }) : this.tags = tags.obs;

  // 从Map创建Staff对象
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] as String,
      name: json['name'] as String, 
      detail: json['detail'] as String,
      tags: List<String>.from(json['tags']),
    );
  }

  // 转换为Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'detail': detail,
      'tags': tags.toList(),
    };
  }
} 