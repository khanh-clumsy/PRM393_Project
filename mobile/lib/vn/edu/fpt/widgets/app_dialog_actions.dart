import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_button.dart';

/// Preset nhãn cho các loại dialog — truyền trực tiếp hoặc override từng field.
class AppDialogLabels {
  final String cancel;
  final String submit;
  final String submitting;
  final Color submitColor;

  const AppDialogLabels({
    this.cancel = 'Hủy',
    required this.submit,
    required this.submitting,
    this.submitColor = const Color(0xFFE65100),
  });

  static const save = AppDialogLabels(submit: 'Lưu', submitting: 'Đang lưu...');
  static const add = AppDialogLabels(submit: 'Thêm', submitting: 'Đang thêm...');
  static const delete = AppDialogLabels(
    submit: 'Xóa',
    submitting: 'Đang xóa...',
    submitColor: Colors.red,
  );
  static const confirm = AppDialogLabels(submit: 'Đồng ý', submitting: 'Đang xử lý...');
  static const confirmDelete = AppDialogLabels(
    submit: 'Đồng ý xóa',
    submitting: 'Đang xóa...',
    submitColor: Colors.red,
  );
  static const logout = AppDialogLabels(submit: 'Đăng xuất', submitting: 'Đang đăng xuất...');
  static const publish = AppDialogLabels(submit: 'Đăng tải', submitting: 'Đang đăng...');
  static const unassign = AppDialogLabels(
    submit: 'Hủy phân công',
    submitting: 'Đang hủy...',
    submitColor: Colors.red,
  );

  /// Chuyển preset add → lưu khi đang sửa.
  AppDialogLabels forEdit() => AppDialogLabels(
        cancel: cancel,
        submit: 'Lưu',
        submitting: 'Đang lưu...',
        submitColor: submitColor,
      );
}

/// Nút Hủy + submit chuẩn cho AlertDialog — tự disable khi đang submit.
class AppDialogActions extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;
  final String cancelLabel;
  final String submitLabel;
  final String submittingLabel;
  final Color submitColor;
  final bool disableCancelWhileSubmitting;
  final bool showCancel;

  const AppDialogActions({
    super.key,
    required this.isSubmitting,
    this.onCancel,
    this.onSubmit,
    this.cancelLabel = 'Hủy',
    this.submitLabel = 'Lưu',
    this.submittingLabel = 'Đang lưu...',
    this.submitColor = const Color(0xFFE65100),
    this.disableCancelWhileSubmitting = false,
    this.showCancel = true,
  });

  static _ResolvedLabels _resolveLabels({
    AppDialogLabels? labels,
    String? cancelLabel,
    String? submitLabel,
    String? submittingLabel,
    Color? submitColor,
  }) {
    return _ResolvedLabels(
      cancel: cancelLabel ?? labels?.cancel ?? 'Hủy',
      submit: submitLabel ?? labels?.submit ?? 'Lưu',
      submitting: submittingLabel ?? labels?.submitting ?? 'Đang lưu...',
      submitColor: submitColor ?? labels?.submitColor ?? const Color(0xFFE65100),
    );
  }

  /// Tiện cho GetX: tự [Obx] theo [RxBool].
  static Widget reactive({
    required RxBool isSubmitting,
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
    AppDialogLabels? labels,
    String? cancelLabel,
    String? submitLabel,
    String? submittingLabel,
    Color? submitColor,
    bool disableCancelWhileSubmitting = false,
    bool showCancel = true,
  }) {
    final resolved = _resolveLabels(
      labels: labels,
      cancelLabel: cancelLabel,
      submitLabel: submitLabel,
      submittingLabel: submittingLabel,
      submitColor: submitColor,
    );
    return Obx(() => AppDialogActions(
          isSubmitting: isSubmitting.value,
          onCancel: onCancel,
          onSubmit: onSubmit,
          cancelLabel: resolved.cancel,
          submitLabel: resolved.submit,
          submittingLabel: resolved.submitting,
          submitColor: resolved.submitColor,
          disableCancelWhileSubmitting: disableCancelWhileSubmitting,
          showCancel: showCancel,
        ));
  }

  /// Dialog không dùng GetX controller — tự quản lý guard nội bộ.
  static Widget guarded({
    required Future<void> Function() onSubmit,
    VoidCallback? onCancel,
    AppDialogLabels? labels,
    String? cancelLabel,
    String? submitLabel,
    String? submittingLabel,
    Color? submitColor,
    bool disableCancelWhileSubmitting = true,
    bool showCancel = true,
  }) {
    final resolved = _resolveLabels(
      labels: labels,
      cancelLabel: cancelLabel,
      submitLabel: submitLabel,
      submittingLabel: submittingLabel,
      submitColor: submitColor,
    );
    return _GuardedDialogActions(
      onSubmit: onSubmit,
      onCancel: onCancel,
      cancelLabel: resolved.cancel,
      submitLabel: resolved.submit,
      submittingLabel: resolved.submitting,
      submitColor: resolved.submitColor,
      disableCancelWhileSubmitting: disableCancelWhileSubmitting,
      showCancel: showCancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCancel = !disableCancelWhileSubmitting || !isSubmitting;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showCancel)
          AppButton(
            label: cancelLabel,
            onPressed: canCancel ? onCancel : null,
            variant: AppButtonVariant.text,
            height: 40,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        AppButton(
          label: submitLabel,
          loadingLabel: submittingLabel,
          onPressed: onSubmit,
          isLoading: isSubmitting,
          loadingStyle: AppButtonLoadingStyle.label,
          color: submitColor,
          height: 40,
          borderRadius: 12,
        ),
      ],
    );
  }
}

class _ResolvedLabels {
  final String cancel;
  final String submit;
  final String submitting;
  final Color submitColor;

  const _ResolvedLabels({
    required this.cancel,
    required this.submit,
    required this.submitting,
    required this.submitColor,
  });
}

class _GuardedDialogActions extends StatefulWidget {
  final Future<void> Function() onSubmit;
  final VoidCallback? onCancel;
  final String cancelLabel;
  final String submitLabel;
  final String submittingLabel;
  final Color submitColor;
  final bool disableCancelWhileSubmitting;
  final bool showCancel;

  const _GuardedDialogActions({
    required this.onSubmit,
    this.onCancel,
    this.cancelLabel = 'Hủy',
    this.submitLabel = 'Lưu',
    this.submittingLabel = 'Đang lưu...',
    this.submitColor = const Color(0xFFE65100),
    this.disableCancelWhileSubmitting = true,
    this.showCancel = true,
  });

  @override
  State<_GuardedDialogActions> createState() => _GuardedDialogActionsState();
}

class _GuardedDialogActionsState extends State<_GuardedDialogActions> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogActions(
      isSubmitting: _isSubmitting,
      onCancel: widget.onCancel,
      onSubmit: _handleSubmit,
      cancelLabel: widget.cancelLabel,
      submitLabel: widget.submitLabel,
      submittingLabel: widget.submittingLabel,
      submitColor: widget.submitColor,
      disableCancelWhileSubmitting: widget.disableCancelWhileSubmitting,
      showCancel: widget.showCancel,
    );
  }
}
