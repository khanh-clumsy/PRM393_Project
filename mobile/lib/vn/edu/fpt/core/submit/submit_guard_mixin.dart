import 'package:get/get.dart';

/// Chặn double-submit cho controller GetX.
///
/// Dùng [runSubmitting] bọc mọi thao tác create/update/delete async.
mixin SubmitGuardMixin on GetxController {
  final RxBool isSubmitting = false.obs;

  Future<void> runSubmitting(Future<void> Function() action) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      await action();
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Đóng dialog đang mở một cách an toàn.
  ///
  /// Nếu còn snackbar từ lần thao tác trước đang hiển thị, [Get.back] có thể
  /// đóng nhầm snackbar thay vì dialog → dialog kẹt lại. Vì vậy dẹp snackbar
  /// trước, rồi chỉ pop khi thực sự đang có dialog.
  void closeDialogSafely() {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
