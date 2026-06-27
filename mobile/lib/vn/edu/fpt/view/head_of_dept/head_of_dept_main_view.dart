import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'head_of_dept_home_view.dart';
import '../shared/account_view.dart';

class HeadOfDeptMainView extends StatefulWidget {
  const HeadOfDeptMainView({super.key});

  @override
  State<HeadOfDeptMainView> createState() => _HeadOfDeptMainViewState();
}

class _HeadOfDeptMainViewState extends State<HeadOfDeptMainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const HeadOfDeptHomeView(), const AccountView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          CustomBottomNavBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Trang chủ',
          ),
          CustomBottomNavBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
