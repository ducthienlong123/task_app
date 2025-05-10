import 'dart:convert';

class TaskModel {
  final String id; // Định danh duy nhất
  final String title; // Tiêu đề công việc
  final String description; // Mô tả chi tiết
  final String status; // Trạng thái công việc
  final int priority; // Độ ưu tiên
  final DateTime? dueDate; // Hạn hoàn thành
  final DateTime createdAt; // Thời gian tạo
  final DateTime updatedAt; // Thời gian cập nhật gần nhất
  final String? assignedTo; // ID người được giao
  final String createdBy; // ID người tạo
  final String? category; // Phân loại công việc
  final List<String>? attachments; // Danh sách link tài liệu đính kèm
  final bool completed; // Trạng thái hoàn thành

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    required this.createdBy,
    this.category,
    this.attachments,
    required this.completed,
  });

  // Chuyển đổi từ TaskModel sang Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'category': category,
      'attachments': attachments != null ? jsonEncode(attachments) : null,
      'completed': completed ? 1 : 0, // SQLite lưu boolean dưới dạng 0/1
    };
  }

  // Tạo TaskModel từ Map lấy từ SQLite
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      priority: map['priority'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      assignedTo: map['assignedTo'],
      createdBy: map['createdBy'],
      category: map['category'],
      attachments: map['attachments'] != null
          ? List<String>.from(jsonDecode(map['attachments']))
          : null,
      completed: map['completed'] == 1, // SQLite lưu boolean dưới dạng 0/1
    );
  }

  // Phương thức copy để tạo bản sao với một số thuộc tính được cập nhật
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    int? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedTo,
    String? createdBy,
    String? category,
    List<String>? attachments,
    bool? completed,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
      completed: completed ?? this.completed,
    );
  }

  @override
  String toString() {
    return 'TaskModel('
        'id: $id, '
        'title: $title, '
        'description: $description, '
        'status: $status, '
        'priority: $priority, '
        'dueDate: $dueDate, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'assignedTo: $assignedTo, '
        'createdBy: $createdBy, '
        'category: $category, '
        'attachments: ${attachments?.join(", ") ?? ""}, '
        'completed: $completed'
        ')';
  }
}