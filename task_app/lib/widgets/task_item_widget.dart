import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskModel task;
    final VoidCallback? onTap; 
  final VoidCallback onDelete;
  final VoidCallback onUpdateStatus;
  final VoidCallback onEdit;

  const TaskItemWidget({
    Key? key,
    required this.task,
    this.onTap,
    required this.onDelete,
    required this.onUpdateStatus,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: onTap,
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Trạng thái: ${task.status}"),
            Text("Độ ưu tiên: ${task.priority}"),

          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút cập nhật trạng thái
            IconButton(
              icon: Icon(
                Icons.check_circle,
                color: task.completed ? Colors.green : Colors.grey,
              ),
              onPressed: onUpdateStatus, // Gọi callback cập nhật trạng thái
            ),
            // Nút chỉnh sửa
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit, // Gọi callback mở màn hình chỉnh sửa
            ),
            // Nút xóa
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete, // Gọi callback xóa công việc
            ),
          ],
        ),
      ),
    );
  }
}