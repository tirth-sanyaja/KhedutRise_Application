import 'package:flutter/material.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import '../../my_farm/screens/my_farm_screen.dart';
import '../../ai_assistant/screens/ai_chat_screen.dart';
import '../../marketplace/screens/land_marketplace_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onSwitchTab: _onTabSelected),
      MyFarmScreen(onSwitchTab: _onTabSelected),
      AiChatScreen(onSwitchTab: _onTabSelected),
      LandMarketplaceScreen(onSwitchTab: _onTabSelected),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
