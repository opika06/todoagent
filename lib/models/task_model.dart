import 'package:get/get.dart';

class Task {
  final String id;
  final String name;
  final String detail;
  final RxBool isCompleted;
  final String staffId;

  Task({
    required this.id,
    required this.name,
    required this.detail,
    required this.staffId,
    bool isCompleted = false,
  }) : isCompleted = isCompleted.obs;

  // 从Map创建Task对象
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      name: json['name'] as String, 
      detail: json['detail'] as String,
      staffId: json['staffId'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  // 转换为Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'detail': detail,
      'staffId': staffId,
      'isCompleted': isCompleted.value,
    };
  }
}