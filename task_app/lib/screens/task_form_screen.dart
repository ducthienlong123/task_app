import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/services/task_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final String userId;
  final TaskModel? task;

  const TaskFormScreen({Key? key, required this.userId, this.task})
      : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _status = "To do";
  int _priority = 1;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  List<String> _attachments = [];
  final TaskService taskService = TaskService();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _dueTime = _dueDate != null ? TimeOfDay.fromDateTime(_dueDate!) : null;
      _attachments = widget.task!.attachments ?? [];
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.userId,
        assignedTo: widget.task?.assignedTo,
        attachments: _attachments,
        completed: widget.task?.completed ?? false,
      );

      if (widget.task == null) {
        await taskService.createTask(task);
      } else {
        await taskService.updateTask(task);
      }

      Navigator.pop(context, true); // Trả về `true` để làm mới danh sách
    }
  }

  // Hàm để chọn tài liệu đính kèm
  void _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _attachments.addAll(result.paths.whereType<String>());
      });
    }
  }

  // Hàm để mở tài liệu đính kèm
  void _openAttachment(String path) async {
    final result = await OpenFile.open(path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể mở tệp: $path")),
      );
    }
  }

  // Hàm để tải tài liệu đính kèm về
  Future<void> _downloadAttachment(String path) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.split('/').last;
      final newPath = '${directory.path}/$fileName';

      final file = File(path);
      await file.copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tệp đã được tải về: $newPath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải tệp: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Thêm Công việc" : "Sửa Công việc"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            tooltip: 'Lưu',
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Tiêu đề *",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Mô tả *",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Vui lòng nhập mô tả' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: ["To do", "In progress", "Done", "Cancelled"]
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Trạng thái *",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _priority,
                  items: [1, 2, 3]
                      .map((priority) => DropdownMenuItem(
                    value: priority,
                    child: Text("Ưu tiên $priority"),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Độ ưu tiên *",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: _dueTime ?? TimeOfDay.now(),
                      );

                      if (selectedTime != null) {
                        setState(() {
                          _dueDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          _dueTime = selectedTime;
                        });
                      }
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ngày đến hạn',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _dueDate != null
                            ? DateFormat('dd/MM/yyyy, hh:mm a').format(_dueDate!)
                            : "",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Nút chọn tài liệu đính kèm
                ElevatedButton.icon(
                  onPressed: _pickAttachments,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Chọn tài liệu đính kèm"),
                ),
                const SizedBox(height: 16),
                // Danh sách hiển thị tài liệu đính kèm
                if (_attachments.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Danh sách tài liệu đính kèm:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._attachments.map((attachment) => ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(attachment.split('/').last),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download, color: Colors.green),
                              onPressed: () => _downloadAttachment(attachment),
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new, color: Colors.blue),
                              onPressed: () => _openAttachment(attachment),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _attachments.remove(attachment);
                                });
                              },
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}