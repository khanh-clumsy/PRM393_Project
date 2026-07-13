import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppButtonVariant {
  primary,
  outlined,
  danger,
  dangerOutlined,
  text,
}

enum AppButtonLoadingStyle {
  spinner,
  label,
}

/// Nút chuẩn toàn app — hỗ trợ label động, loading, icon, full-width.
class AppButton extends StatelessWidget {
  static const Color primaryColor = Color(0xFFE65100);
  static const Color primaryDark = Color(0xFF9E400A);

  final String label;
  final String? loadingLabel;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final double height;
  final double borderRadius;
  final AppButtonLoadingStyle loadingStyle;
  final Color? color;
  final TextStyle? labelStyle;

  const AppButton({
    super.key,
    required this.label,
    this.loadingLabel,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
    this.height = 48,
    this.borderRadius = 12,
    this.loadingStyle = AppButtonLoadingStyle.spinner,
    this.color,
    this.labelStyle,
  });

  /// Nút "Thử lại" cho màn hình lỗi.
  factory AppButton.retry({
    Key? key,
    required VoidCallback onPressed,
  }) {
    return AppButton(
      key: key,
      label: 'Thử lại',
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
    );
  }

  /// Tự [Obx] theo [RxBool] loading (GetX).
  static Widget reactive({
    Key? key,
    required RxBool isLoading,
    required String label,
    String? loadingLabel,
    VoidCallback? onPressed,
    AppButtonVariant variant = AppButtonVariant.primary,
    IconData? icon,
    bool fullWidth = false,
    double height = 48,
    double borderRadius = 12,
    AppButtonLoadingStyle loadingStyle = AppButtonLoadingStyle.spinner,
    Color? color,
    TextStyle? labelStyle,
  }) {
    return Obx(() => AppButton(
          key: key,
          label: label,
          loadingLabel: loadingLabel,
          onPressed: onPressed,
          isLoading: isLoading.value,
          variant: variant,
          icon: icon,
          fullWidth: fullWidth,
          height: height,
          borderRadius: borderRadius,
          loadingStyle: loadingStyle,
          color: color,
          labelStyle: labelStyle,
        ));
  }

  /// Dialog / form không có controller — tự guard async nội bộ.
  static Widget guarded({
    Key? key,
    required String label,
    String? loadingLabel,
    required Future<void> Function() onPressed,
    AppButtonVariant variant = AppButtonVariant.primary,
    IconData? icon,
    bool fullWidth = false,
    double height = 48,
    double borderRadius = 12,
    Color? color,
  }) {
    return _GuardedAppButton(
      key: key,
      label: label,
      loadingLabel: loadingLabel,
      onPressed: onPressed,
      variant: variant,
      icon: icon,
      fullWidth: fullWidth,
      height: height,
      borderRadius: borderRadius,
      color: color,
    );
  }

  Color get _baseColor {
    if (color != null) return color!;
    return switch (variant) {
      AppButtonVariant.danger || AppButtonVariant.dangerOutlined => Colors.red,
      AppButtonVariant.text => primaryColor,
      _ => primaryColor,
    };
  }

  bool get _disabled => isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final child = _buildChild();
    final sized = SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: child,
    );
    return sized;
  }

  Widget _buildChild() {
    return switch (variant) {
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: _disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _baseColor,
            side: BorderSide(color: _disabled ? _baseColor.withValues(alpha: 0.4) : _baseColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: _buildContent(fallbackColor: _baseColor, bold: true),
        ),
      AppButtonVariant.dangerOutlined => OutlinedButton(
          onPressed: _disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: BorderSide(color: _disabled ? Colors.red.withValues(alpha: 0.4) : Colors.red, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: _buildContent(fallbackColor: Colors.red, bold: true),
        ),
      AppButtonVariant.text => TextButton(
          onPressed: _disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _baseColor,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: _buildLabel(fallbackColor: _baseColor),
        ),
      _ => ElevatedButton(
          onPressed: _disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _baseColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _baseColor.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white70,
            elevation: variant == AppButtonVariant.danger ? 0 : 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: _buildContent(fallbackColor: Colors.white, bold: true),
        ),
    };
  }

  Widget _buildContent({required Color fallbackColor, bool bold = false}) {
    final labelWidget = _buildLabel(fallbackColor: fallbackColor, bold: bold);
    if (isLoading && loadingStyle == AppButtonLoadingStyle.spinner && icon == null) {
      return labelWidget;
    }
    final iconWidget = _buildIcon(fallbackColor: fallbackColor);
    if (iconWidget == null) return labelWidget;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconWidget,
        const SizedBox(width: 8),
        labelWidget,
      ],
    );
  }

  Widget _buildLabel({required Color fallbackColor, bool bold = false}) {
    if (isLoading && loadingStyle == AppButtonLoadingStyle.spinner && icon == null) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: fallbackColor),
      );
    }

    final text = isLoading && loadingLabel != null ? loadingLabel! : label;
    return Text(
      text,
      style: labelStyle ??
          TextStyle(
            fontSize: variant == AppButtonVariant.text ? 13 : 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: variant == AppButtonVariant.text ? fallbackColor : null,
          ),
    );
  }

  Widget? _buildIcon({required Color fallbackColor}) {
    if (isLoading && loadingStyle == AppButtonLoadingStyle.spinner) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: fallbackColor),
      );
    }
    if (icon == null) return null;
    return Icon(icon, size: 20);
  }
}

class _GuardedAppButton extends StatefulWidget {
  final String label;
  final String? loadingLabel;
  final Future<void> Function() onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final double height;
  final double borderRadius;
  final Color? color;

  const _GuardedAppButton({
    super.key,
    required this.label,
    this.loadingLabel,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
    this.height = 48,
    this.borderRadius = 12,
    this.color,
  });

  @override
  State<_GuardedAppButton> createState() => _GuardedAppButtonState();
}

class _GuardedAppButtonState extends State<_GuardedAppButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: widget.label,
      loadingLabel: widget.loadingLabel,
      onPressed: _handlePress,
      isLoading: _isLoading,
      variant: widget.variant,
      icon: widget.icon,
      fullWidth: widget.fullWidth,
      height: widget.height,
      borderRadius: widget.borderRadius,
      color: widget.color,
    );
  }
}

/// FAB chuẩn — màu cam, bo góc 16.
class AppFab {
  AppFab._();

  static Widget add({
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppButton.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  static Widget extended({
    required VoidCallback onPressed,
    required String label,
    IconData icon = Icons.add,
    String? tooltip,
  }) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppButton.primaryColor,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
