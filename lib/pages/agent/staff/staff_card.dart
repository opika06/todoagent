import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/staff_model.dart';
import 'edit_staff_page.dart';

class StaffCard extends StatelessWidget {
  final Staff staff;

  const StaffCard({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey, width: 1.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap:
            () => Get.to(
              () => EditStaffPage(staff: staff),
              transition: Transition.rightToLeft,
            ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 头像
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.blue.shade50,
                child: Text(
                  staff.name.isNotEmpty ? staff.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 名称
              Text(
                staff.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
