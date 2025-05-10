import '../models/user_model.dart';
import 'database_helper.dart';

class UserService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Thêm user mới
  Future<void> createUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert('users', user.toMap());
  }

  // Lấy thông tin user theo ID
  Future<UserModel?> getUserById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  // Cập nhật thông tin user
  Future<void> updateUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Xóa user
  Future<void> deleteUser(String id) async {
    final db = await _dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Cập nhật thời gian hoạt động gần nhất
  Future<void> updateUserLastActive(String userId) async {
    final db = await _dbHelper.database;
    await db.update('users', {'lastActive': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [userId]);
  }

  // Kiểm tra xem người dùng đã tồn tại chưa
  Future<bool> checkUserExists(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    return result.isNotEmpty;
  }

  // Lấy danh sách tất cả người dùng
  Future<List<UserModel>> getAllUsers() async {
    final db = await _dbHelper.database;
    final result = await db.query('users');
    return result.map((map) => UserModel.fromMap(map)).toList();
  }
}