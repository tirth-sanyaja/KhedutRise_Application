import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'All';

  final List<String> _filters = ['All', 'Weather', 'Tasks', 'Market', 'AI'];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'category': 'Weather',
      'title': 'Rainfall Expected in 24 Hours',
      'description':
          'Light to moderate rain (12-18mm) forecast in Sardhar & Rajkot rural. Postpone open field urea spraying.',
      'time': '10 mins ago',
      'isRead': false,
      'icon': Icons.thunderstorm_outlined,
      'color': const Color(0xFF0284C7),
    },
    {
      'id': '2',
      'category': 'Tasks',
      'title': 'Plot A Irrigation Reminder',
      'description':
          'Scheduled drip irrigation for Cotton (Plot A) today at 5:00 PM.',
      'time': '1 hour ago',
      'isRead': false,
      'icon': Icons.water_drop_outlined,
      'color': const Color(0xFF16A34A),
    },
    {
      'id': '3',
      'category': 'AI',
      'title': 'Leaf Scan Result Ready',
      'description':
          'Diagnostic complete: Early Stage Nitrogen Deficiency detected in Wheat crop sample. NPK 19-19-19 recommended.',
      'time': '3 hours ago',
      'isRead': false,
      'icon': Icons.auto_awesome,
      'color': const Color(0xFF7C3AED),
    },
    {
      'id': '4',
      'category': 'Market',
      'title': 'Cotton APMC Price Surge',
      'description':
          'Rajkot APMC Shankar-6 cotton rates reached ₹7,450/quintal (+₹180 today). Good time to review mandi sell options.',
      'time': 'Yesterday',
      'isRead': true,
      'icon': Icons.trending_up,
      'color': const Color(0xFFD97706),
    },
    {
      'id': '5',
      'category': 'Market',
      'title': 'New Farmland Listed Near You',
      'description':
          '5.2 Acres Black Soil land listed in Kotda Sangani, 6km from your registered farm.',
      'time': '2 days ago',
      'isRead': true,
      'icon': Icons.landscape_outlined,
      'color': const Color(0xFF059669),
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_activeFilter == 'All') return true;
      return n['category'] == _activeFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KhedutAppBar(
        title: 'Notifications',
        subtitle: 'Alerts & Farm Updates',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Read All',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final f = _filters[index];
                  final isSelected = _activeFilter == f;
                  return ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _activeFilter = f),
                    selectedColor: AppColors.primaryDark,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.borderLight,
                      ),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const Divider(height: 1),

            // Notification list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 54,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications in this category',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = filtered[index];
                        final isRead = n['isRead'] as bool;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              n['isRead'] = true;
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? Colors.white
                                  : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isRead
                                    ? AppColors.borderLight
                                    : const Color(0xFFA7F3D0),
                                width: isRead ? 1 : 1.4,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: (n['color'] as Color).withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    n['icon'] as IconData,
                                    color: n['color'] as Color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n['title'],
                                              style: AppTypography.titleSmall
                                                  .copyWith(
                                                    fontWeight: isRead
                                                        ? FontWeight.w600
                                                        : FontWeight.w800,
                                                    fontSize: 14,
                                                  ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n['description'],
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        n['time'],
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
