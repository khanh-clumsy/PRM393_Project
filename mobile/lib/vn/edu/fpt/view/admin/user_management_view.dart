import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';

class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    final List<Map<String, dynamic>> tabs = [
      {'id': 4, 'label': 'Học sinh'},
      {'id': 3, 'label': 'Giáo viên'},
      {'id': 5, 'label': 'Phụ huynh'},
      {'id': 2, 'label': 'Trưởng khoa'},
      {'id': 1, 'label': 'Admin'},
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: AppBar(
          title: const Text('Quản lý Tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            labelColor: const Color(0xFFE65100),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFE65100),
            tabs: tabs.map((t) => Tab(text: t['label'])).toList(),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text(controller.errorMessage.value, style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.fetchUsers,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            children: tabs.map((t) {
              final roleId = t['id'] as int;
              final filteredUsers = controller.users.where((u) => u.roleId == roleId).toList();

              if (filteredUsers.isEmpty) {
                return const Center(child: Text('Chưa có dữ liệu tài khoản.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE3F2FD),
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user.username), // No need to show roleName since they are in a specific tab
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () => _showFormDialog(context, controller, user: user, defaultRoleId: roleId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _showDeleteConfirm(context, controller, user),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        }),
        floatingActionButton: Builder(
          builder: (ctx) {
            return FloatingActionButton(
              onPressed: () {
                final currentTabIndex = DefaultTabController.of(ctx).index;
                final defaultRoleId = tabs[currentTabIndex]['id'] as int;
                _showFormDialog(context, controller, defaultRoleId: defaultRoleId);
              },
              backgroundColor: const Color(0xFFE65100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, UserController controller, {UserModel? user, int defaultRoleId = 4}) {
    final isEditing = user != null;
    final usernameController = TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController();
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');

    int selectedRoleId = user?.roleId ?? defaultRoleId;
    int? selectedDepartmentId = user?.departmentId;

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Sửa Tài Khoản' : 'Thêm Tài Khoản', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isEditing)
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Tên đăng nhập (Username) *',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  if (!isEditing) const SizedBox(height: 16),
                  if (!isEditing)
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu *',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  if (!isEditing) const SizedBox(height: 16),
                  
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Họ và tên *',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Vai trò (Role) *',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    value: selectedRoleId,
                    items: controller.roles.map((r) {
                      return DropdownMenuItem<int>(
                        value: r['id'] as int,
                        child: Text(r['name'] as String),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedRoleId = val ?? 4;
                        if (selectedRoleId != 2 && selectedRoleId != 3) {
                          selectedDepartmentId = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  if ((selectedRoleId == 2 || selectedRoleId == 3) && controller.departments.isNotEmpty)
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Phòng ban (Bắt buộc cho Giáo viên/Trưởng khoa)',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      value: selectedDepartmentId,
                      items: controller.departments.map((d) {
                        return DropdownMenuItem<int>(
                          value: d.departmentId,
                          child: Text(d.departmentName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedDepartmentId = val;
                        });
                      },
                    ),
                  if ((selectedRoleId == 2 || selectedRoleId == 3) && controller.departments.isNotEmpty)
                    const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final username = usernameController.text.trim();
                final password = passwordController.text.trim();
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty) {
                  Get.snackbar('Lỗi', 'Họ tên không được để trống', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }

                if (!isEditing && (username.isEmpty || password.isEmpty)) {
                  Get.snackbar('Lỗi', 'Tài khoản và Mật khẩu không được để trống', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }

                if ((selectedRoleId == 2 || selectedRoleId == 3) && selectedDepartmentId == null) {
                   Get.snackbar('Lỗi', 'Giáo viên/Trưởng khoa phải có bộ môn', backgroundColor: Colors.redAccent, colorText: Colors.white);
                   return;
                }

                if (isEditing) {
                  controller.updateUser(
                    user.userId, 
                    name, 
                    selectedRoleId, 
                    selectedDepartmentId, 
                    email.isEmpty ? null : email, 
                    phone.isEmpty ? null : phone
                  );
                } else {
                  controller.createUser(
                    username, 
                    password, 
                    name, 
                    selectedRoleId, 
                    selectedDepartmentId, 
                    email.isEmpty ? null : email, 
                    phone.isEmpty ? null : phone
                  );
                }
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, UserController controller, UserModel user) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa tài khoản "${user.username}" không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              controller.deleteUser(user.userId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
