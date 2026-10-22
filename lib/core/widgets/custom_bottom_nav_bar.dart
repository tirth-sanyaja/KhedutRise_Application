import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                  _buildNavItem(1, Icons.eco_outlined, Icons.eco, 'My Farm'),
                  _buildNavItem(
                    2,
                    Icons.smart_toy_outlined,
                    Icons.smart_toy,
                    'AI Chat',
                  ),
                  _buildNavItem(
                    3,
                    Icons.agriculture_outlined,
                    Icons.agriculture,
                    'Services',
                  ),
                  _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryDark : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
