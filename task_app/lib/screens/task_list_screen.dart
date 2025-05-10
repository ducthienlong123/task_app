import 'package:flutter/material.dart';
import '../screens/task_form_screen.dart';
import '../screens/task_detail_screen.dart';
import '../widgets/task_item_widget.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../screens/login.dart';

class TaskListScreen extends StatefulWidget {
  final String userId;

  const TaskListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = "";
  int? _filterPriority; // Biến lưu trạng thái lọc ưu tiên (null = tất cả)

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _taskService.getTasksByUserId(widget.userId);
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải công việc: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _handleSearch(String query) async {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      _refreshNotes(); // Nếu không có từ khóa, tải lại toàn bộ danh sách
    } else {
      try {
        final tasks = await _taskService.searchTasks(widget.userId, query);
        setState(() {
          _tasks = tasks;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tìm kiếm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleFilter(int? priority) {
    setState(() {
      _filterPriority = priority; // Cập nhật trạng thái lọc
    });
  }

  List<TaskModel> _getFilteredTasks() {
    if (_filterPriority == null) {
      return _tasks; // Không lọc, trả về tất cả công việc
    }
    return _tasks.where((task) => task.priority == _filterPriority).toList();
  }

  void _goToDetailScreen(TaskModel task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
    if (result == true) {
      _refreshNotes(); // Làm mới danh sách sau khi quay lại từ màn hình chi tiết
    }
  }

  void _goToFormScreen({TaskModel? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(userId: widget.userId, task: task),
      ),
    );
    if (result == true) {
      _refreshNotes(); // Làm mới danh sách sau khi thêm hoặc sửa công việc
    }
  }

  void _deleteTask(String taskId) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc chắn muốn xóa công việc này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _taskService.deleteTaskById(taskId, widget.userId);
        _refreshNotes(); // Làm mới danh sách sau khi xóa công việc
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa công việc')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateTaskStatus(TaskModel task) async {
    try {
      final updatedTask = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        status: task.status == "Done" ? "To do" : "Done", // Đảo trạng thái
        priority: task.priority,
        dueDate: task.dueDate,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        createdBy: task.createdBy,
        assignedTo: task.assignedTo,
        attachments: task.attachments,
        completed: !task.completed, // Đảo trạng thái hoàn thành
      );

      await _taskService.updateTask(updatedTask);
      _refreshNotes(); // Làm mới danh sách sau khi cập nhật trạng thái
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật trạng thái: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Đăng xuất
  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthMethods().signOut(context); // Đăng xuất người dùng
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LogIn()), // Chuyển về màn hình đăng nhập
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks(); // Lọc danh sách công việc

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách Công việc"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công việc...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearch('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _handleSearch,
            ),
          ),
        ),
        actions: [
          // // Nút tìm kiếm
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () async {
          //     final result = await showSearch(
          //       context: context,
          //       delegate: TaskSearchDelegate(_tasks),
          //     );
          //     if (result != null) {
          //       setState(() {
          //         _searchQuery = result;
          //       });
          //     }
          //   },
          // ),
          PopupMenuButton<int?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Lọc theo ưu tiên',
            onSelected: (value) {
              _handleFilter(value == -1 ? null : value);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int?>>[
              const PopupMenuItem<int?>(
                value: -1,
                child: Text('Tất cả ưu tiên'),
              ),
              // const PopupMenuDivider(),
              const PopupMenuItem<int?>(
                value: 3,
                child: Text('Ưu tiên: 3: Cao'),
              ),
              const PopupMenuItem<int?>(
                value: 2,
                child: Text('Ưu tiên: 2: Trung bình'),
              ),
              const PopupMenuItem<int?>(
                value: 1,
                child: Text('Ưu tiên: 1: Thấp'),
              ),
            ],
          ),
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   tooltip: 'Làm mới',
          //   onPressed: _refreshNotes,
          // ),
          // Nút đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredTasks.isEmpty
          ? const Center(
        child: Text(
          'Không có công việc nào.\nNhấn + để thêm.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return TaskItemWidget(
            task: task,
            onTap: () => _goToDetailScreen(task),
            onEdit: () => _goToFormScreen(task: task),
            onUpdateStatus: () => _updateTaskStatus(task),
            onDelete: () => _deleteTask(task.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToFormScreen(),
        tooltip: 'Thêm công việc mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}
class TaskSearchDelegate extends SearchDelegate<String> {
  final List<TaskModel> tasks;

  TaskSearchDelegate(this.tasks);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredTasks = tasks
        .where((task) =>
    task.title.toLowerCase().contains(query.toLowerCase()) ||
        task.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return filteredTasks.isEmpty
        ? const Center(child: Text("Không tìm thấy công việc nào."))
        : ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          onTap: () {
            close(context, task.title);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = tasks
        .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return suggestions.isEmpty
        ? const Center(child: Text("Không có gợi ý nào."))
        : ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final task = suggestions[index];
        return ListTile(
          title: Text(task.title),
          onTap: () {
            query = task.title;
            showResults(context);
          },
        );
      },
    );
  }
}