import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_app/screens/task_list_screen.dart';
import 'package:task_app/services/user_service.dart';
import '../models/user_model.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final UserService userService = UserService();

  // Lấy user hiện tại
  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  // Đăng nhập bằng email và mật khẩu
  Future<void> signInWithEmail(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Kiểm tra và lấy thông tin người dùng từ SQLite
        final existingUser = await userService.getUserById(user.uid);
        if (existingUser != null) {
          // Cập nhật thời gian hoạt động gần nhất
          await userService.updateUserLastActive(user.uid);

          // Chuyển hướng đến màn hình TaskListScreen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => TaskListScreen(userId: user.uid)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Người dùng không tồn tại trong hệ thống.")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng nhập thất bại: ${e.toString()}")));
    }
  }

  // Đăng ký tài khoản mới
  Future<void> signUpWithEmail(
      String email, String password, String username, BuildContext context) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Tạo đối tượng UserModel mới
        UserModel newUser = UserModel(
          id: user.uid,
          username: username,
          email: email,
          avatar: null,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
          isAdmin: false, // Mặc định là người dùng thường
        );

        // Lưu thông tin người dùng vào SQLite
        await userService.createUser(newUser);

        // Chuyển hướng đến màn hình TaskListScreen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => TaskListScreen(userId: user.uid)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng ký thất bại: ${e.toString()}")));
    }
  }

  // Đăng nhập bằng Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Bắt đầu quá trình đăng nhập Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        return;
      }

      // Lấy thông tin xác thực từ Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo thông tin xác thực Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Kiểm tra xem người dùng đã tồn tại trong SQLite chưa
        final userExists = await userService.checkUserExists(user.uid);

        if (!userExists) {
          // Tạo đối tượng UserModel mới
          UserModel newUser = UserModel(
            id: user.uid,
            username: user.displayName ?? "Người dùng",
            email: user.email ?? "",
            avatar: null,
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
            isAdmin: false, // Mặc định là người dùng thường
          );

          // Lưu thông tin người dùng vào SQLite
          await userService.createUser(newUser);
        } else {
          // Cập nhật thời gian hoạt động gần nhất
          await userService.updateUserLastActive(user.uid);
        }

        // Chuyển hướng đến màn hình TaskListScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TaskListScreen(userId: user.uid),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập bằng Google thất bại: $e")),
      );
    }
  }

  // Đăng xuất
  Future<void> signOut(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Đăng xuất"),
          ),
        ],
      ),
    );

    if (confirm) {
      await auth.signOut();
      await googleSignIn.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng xuất thành công.")),
      );
    }
  }
}