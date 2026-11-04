import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../balance/presentation/pages/accueil_tab.dart';
import '../../../projet/presentation/pages/objectifs_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../sortie/presentation/pages/add_expense_page.dart';
import '../../../sortie/presentation/pages/reports_page.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    AccueilTab(),
    ReportsPage(),
    SizedBox(), // Placeholder for center (+) button
    ObjectifsPage(),
    ProfilePage(),
  ];

  void _onTabSelected(int index) {
    if (index == 2) {
      // Center '+' button opens Add Expense page modal/sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddExpensePage(),
        ),
      ).then((_) {
        if (mounted) setState(() {});
      });
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, "Accueil"),
                _buildNavItem(1, Icons.insert_chart_rounded, Icons.insert_chart_outlined_rounded, "Rapports"),
                _buildCenterAddButton(),
                _buildNavItem(3, Icons.track_changes_rounded, Icons.track_changes_outlined, "Objectifs"),
                _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, "Profil"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabSelected(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? AppColors.primaryGreen : AppColors.textLight,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primaryGreen : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () => _onTabSelected(2),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
