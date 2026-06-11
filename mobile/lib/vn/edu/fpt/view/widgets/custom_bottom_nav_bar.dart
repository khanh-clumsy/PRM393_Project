import 'package:flutter/material.dart';

/// Model đại diện cho một tab trên thanh điều hướng dưới.
class CustomBottomNavBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int badgeCount;
  final bool showBadge;

  const CustomBottomNavBarItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount = 0,
    this.showBadge = false,
  });
}

/// Widget Bottom Navigation Bar tái sử dụng cao với thiết kế hiện đại và micro-animations.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<CustomBottomNavBarItem> items;
  final ValueChanged<int> onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.selectedColor = const Color(0xFFE65100), // Cam FSchools làm mặc định
    this.unselectedColor = Colors.grey,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => Expanded(
                child: NavBarItemWidget(
                  index: index,
                  isSelected: index == currentIndex,
                  item: items[index],
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget con cho từng tab riêng lẻ, tích hợp hiệu ứng Scale và Badge.
class NavBarItemWidget extends StatefulWidget {
  final int index;
  final bool isSelected;
  final CustomBottomNavBarItem item;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const NavBarItemWidget({
    super.key,
    required this.index,
    required this.isSelected,
    required this.item,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  State<NavBarItemWidget> createState() => _NavBarItemWidgetState();
}

class _NavBarItemWidgetState extends State<NavBarItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NavBarItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      // Nháy nhẹ khi được chọn
      _animationController.forward().then((_) => _animationController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIcon = widget.item.activeIcon ?? widget.item.icon;
    final color = widget.isSelected ? widget.selectedColor : widget.unselectedColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon với Badge thông báo (nếu có)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  widget.isSelected ? activeIcon : widget.item.icon,
                  color: color,
                  size: 26,
                ),
                if (widget.item.showBadge || widget.item.badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: widget.item.badgeCount > 0
                          ? Center(
                              child: Text(
                                '${widget.item.badgeCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Nhãn văn bản
            Text(
              widget.item.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Thanh chỉ báo hoạt động (Active Indicator Dot)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: widget.isSelected ? 12 : 0,
              decoration: BoxDecoration(
                color: widget.selectedColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
