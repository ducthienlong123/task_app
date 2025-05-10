class UserModel {
  final String id; // Định danh duy nhất của người dùng
  final String username; // Tên đăng nhập
  final String email; // Email người dùng
  final String? avatar; // URL avatar (có thể null)
  final DateTime createdAt; // Thời gian tạo tài khoản
  final DateTime lastActive; // Thời gian hoạt động gần nhất
  final bool isAdmin; // Xác định quyền Admin (true: Admin, false: Người dùng thường)

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
    this.isAdmin = false, // Mặc định là người dùng thường
  });

  // Chuyển đổi từ UserModel sang Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isAdmin': isAdmin ? 1 : 0, // SQLite lưu boolean dưới dạng 0/1
    };
  }

  // Tạo UserModel từ Map lấy từ SQLite
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      avatar: map['avatar'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
      isAdmin: map['isAdmin'] == 1, // SQLite lưu boolean dưới dạng 0/1
    );
  }

  // Phương thức copy để tạo bản sao với một số thuộc tính được cập nhật
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  String toString() {
    return 'UserModel('
        'id: $id, '
        'username: $username, '
        'email: $email, '
        'avatar: $avatar, '
        'createdAt: $createdAt, '
        'lastActive: $lastActive, '
        'isAdmin: $isAdmin'
        ')';
  }
}