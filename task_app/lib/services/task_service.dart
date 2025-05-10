import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';
import 'database_helper.dart';

class TaskService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Thêm công việc mới
  Future<int> createTask(TaskModel task) async {
    final db = await _dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  // Lấy danh sách công việc theo người dùng
  Future<List<TaskModel>> getTasksByUserId(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'createdBy = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    print("Dữ liệu trong SQLite:");
    for (var row in result) {
      print(row);
    }

    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  // Lấy công việc theo ID
  Future<TaskModel?> getTaskById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return TaskModel.fromMap(result.first);
    }
    return null;
  }

  // Cập nhật công việc
  Future<int> updateTask(TaskModel task) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ? AND createdBy = ?', // Lọc theo id và createdBy
      whereArgs: [task.id, task.createdBy],
    );
  }

  // Xóa công việc theo ID
  Future<int> deleteTaskById(String id, String userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ? AND createdBy = ?', // Lọc theo id và createdBy
      whereArgs: [id, userId],
    );
  }

  // Lấy công việc theo mức độ ưu tiên
  Future<List<TaskModel>> getTasksByPriority(String userId, int priority) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'createdBy = ? AND priority = ?', // Lọc theo createdBy và priority
      whereArgs: [userId, priority],
      orderBy: 'createdAt DESC',
    );

    print("Dữ liệu lọc theo ưu tiên ($priority):");
    for (var row in result) {
      print(row);
    }

    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  // Tìm kiếm công việc theo từ khóa
  Future<List<TaskModel>> searchTasks(String userId, String query) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'createdBy = ? AND (title LIKE ? OR description LIKE ?)',
      // Tìm kiếm trong title và description
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    print("Kết quả tìm kiếm ($query):");
    for (var row in result) {
      print(row);
    }

    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  // Đếm số lượng công việc của người dùng hiện tại
  Future<int> countTasks(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM tasks WHERE createdBy = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Đóng database
  Future<void> close() async {
    final db = await _dbHelper.database;
    db.close();
  }
}