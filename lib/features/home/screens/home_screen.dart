import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/farmer_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  // Comprehensive searchable catalog across KhedutRise
  final List<Map<String, dynamic>> _catalog = [
    {
      'title': 'Wheat Crop (Gehun)',
      'subtitle': 'Current Crop • Plot A • Day 45/120',
      'category': 'Crop',
      'icon': Icons.eco,
      'route': '/my-farm',
      'tabIndex': 1,
      'keywords': [
        'wheat',
        'gehun',
        'crop',
        'plot a',
        'rabi',
        'sowing',
        'harvest',
      ],
    },
    {
      'title': 'Cotton Field (Kapas)',
      'subtitle': 'Plot B • Kharif Season • Drip Irrigated',
      'category': 'Crop',
      'icon': Icons.local_florist,
      'route': '/my-farm',
      'tabIndex': 1,
      'keywords': ['cotton', 'kapas', 'crop', 'plot b', 'kharif', 'fertilizer'],
    },
    {
      'title': 'Mahindra 575 DI XP Plus',
      'subtitle': '47 HP • ₹650/hr • Rotavator attached',
      'category': 'Machinery',
      'icon': Icons.agriculture,
      'route': '/tractor_hire',
      'keywords': ['mahindra', 'tractor', 'rotavator', 'hire', 'rent', '47 hp'],
    },
    {
      'title': 'John Deere 5050 D 4WD',
      'subtitle': '50 HP • ₹750/hr • Heavy Duty Plough',
      'category': 'Machinery',
      'icon': Icons.agriculture,
      'route': '/tractor_hire',
      'keywords': ['john deere', 'tractor', 'plough', 'hire', '50 hp', '4wd'],
    },
    {
      'title': 'Kubota Neostar B2741S (4WD)',
      'subtitle': '27 HP • ₹450/hr • Orchard Sprayer',
      'category': 'Machinery',
      'icon': Icons.agriculture,
      'route': '/tractor_hire',
      'keywords': ['kubota', 'mini tractor', 'sprayer', 'orchard', '27 hp'],
    },
    {
      'title': 'Claas Crop Tiger 30 Harvester',
      'subtitle': '60 HP • ₹1,800/acre • Wheat & Paddy Cutter',
      'category': 'Machinery',
      'icon': Icons.agriculture,
      'route': '/tractor_hire',
      'keywords': ['harvester', 'claas', 'combine', 'crop tiger', 'cutter'],
    },
    {
      'title': 'Automatic Laser Land Leveler',
      'subtitle': 'Laser Guided • ₹550/hr • Water Saver',
      'category': 'Machinery',
      'icon': Icons.architecture,
      'route': '/tractor_hire',
      'keywords': [
        'laser',
        'leveler',
        'land leveler',
        'implement',
        'water saver',
      ],
    },
    {
      'title': 'AI Assistant & Crop Doctor',
      'subtitle': 'Chat with AI for disease diagnosis & advisory',
      'category': 'Service',
      'icon': Icons.auto_awesome,
      'route': '/ai-chat',
      'tabIndex': 2,
      'keywords': [
        'ai',
        'chat',
        'assistant',
        'doctor',
        'crop doctor',
        'disease',
        'advisor',
      ],
    },
    {
      'title': 'Smart Crop Advisor',
      'subtitle': 'Soil-based yield planning & seed suggestions',
      'category': 'Service',
      'icon': Icons.psychology,
      'route': '/crop_advisor',
      'keywords': ['advisor', 'yield', 'soil', 'smart', 'planning', 'seed'],
    },
    {
      'title': 'Land Marketplace',
      'subtitle': 'Verified farmland listings for sale/rent',
      'category': 'Marketplace',
      'icon': Icons.flag,
      'route': '/land_marketplace',
      'tabIndex': 3,
      'keywords': [
        'land',
        'farmland',
        'market',
        'buy',
        'sell',
        'plot',
        'acres',
      ],
    },
    {
      'title': 'Crop Calendar & Schedules',
      'subtitle': 'Timeline for irrigation, fertilizer & pest control',
      'category': 'Service',
      'icon': Icons.calendar_month,
      'route': '/crop_calendar',
      'keywords': [
        'calendar',
        'timeline',
        'schedule',
        'irrigation',
        'spray',
        'task',
      ],
    },
    {
      'title': 'Farm Expenses & Accounts',
      'subtitle': 'Track seeds, fertilizer, fuel & labor costs',
      'category': 'Service',
      'icon': Icons.account_balance_wallet,
      'route': '/farm_expenses',
      'keywords': [
        'expense',
        'cost',
        'money',
        'budget',
        'account',
        'profit',
        'spend',
      ],
    },
    {
      'title': 'Scan Crop Leaf for Disease',
      'subtitle': 'Instant AI photo diagnosis of pest damage',
      'category': 'Service',
      'icon': Icons.document_scanner,
      'route': '/scan_leaf',
      'keywords': [
        'scan',
        'leaf',
        'photo',
        'camera',
        'fungus',
        'disease',
        'pest',
      ],
    },
    {
      'title': 'Land Records & 7/12 Documents',
      'subtitle': 'AnyRoR verified revenue land records & 8A',
      'category': 'Service',
      'icon': Icons.assignment,
      'route': '/profile',
      'tabIndex': 4,
      'keywords': [
        '7/12',
        '8a',
        'anyror',
        'khata',
        'survey',
        'record',
        'land record',
      ],
    },
  ];

  List<Map<String, dynamic>> get _searchResults {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return [];

    return _catalog.where((item) {
      final titleMatch = item['title'].toString().toLowerCase().contains(query);
      final subtitleMatch = item['subtitle'].toString().toLowerCase().contains(
        query,
      );
      final categoryMatch = item['category'].toString().toLowerCase().contains(
        query,
      );
      final keywords = item['keywords'] as List<String>? ?? [];
      final keywordMatch = keywords.any(
        (k) => k.contains(query) || query.contains(k),
      );
      return titleMatch || subtitleMatch || categoryMatch || keywordMatch;
    }).toList();
  }

  void _onNavigateItem(Map<String, dynamic> item) {
    FocusScope.of(context).unfocus();
    final tabIndex = item['tabIndex'] as int?;
    if (tabIndex != null && widget.onSwitchTab != null) {
      widget.onSwitchTab!(tabIndex);
    } else {
      final route = item['route'] as String;
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: ListenableBuilder(
          listenable: FarmerService.instance,
          builder: (context, _) {
            final farmer = FarmerService.instance.currentFarmer;
            final farmerName = farmer?.displayName ?? AppConstants.farmerName;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.55,
                  ),
                  child: Text(
                    farmerName,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications,
                  color: AppColors.primaryDark,
                  size: 28,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          ListenableBuilder(
            listenable: FarmerService.instance,
            builder: (context, _) {
              final initials = FarmerService.instance.farmerInitials;
              return GestureDetector(
                onTap: () {
                  if (widget.onSwitchTab != null) {
                    widget.onSwitchTab!(4);
                  } else {
                    Navigator.pushNamed(context, '/profile');
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16, left: 4),
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Weather Card (shown only if not searching)
              if (_searchQuery.isEmpty) ...[
                _buildWeatherCard(),
                const SizedBox(height: 18),
              ],

              // Functional Search Bar
              _buildSearchBar(context),
              const SizedBox(height: 20),

              // If searching: display Search Results or No Results Found
              if (_searchQuery.isNotEmpty) ...[
                _buildSearchResultsView(),
              ] else ...[
                // Quick Services Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Services',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.onSwitchTab != null) {
                          widget.onSwitchTab!(3);
                        } else {
                          Navigator.pushNamed(context, '/land_marketplace');
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            'See All',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quick Services Grid
                _buildServicesGrid(context),
                const SizedBox(height: 22),

                // Today's Farming Tasks
                _buildTodayTasksCard(context),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    final farmer = FarmerService.instance.currentFarmer;
    final locationText = farmer != null && farmer.village.isNotEmpty
        ? '${farmer.village}, ${farmer.district}'
        : 'Sardhar, Rajkot';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB800),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '32°C Sunny',
                style: AppTypography.headline.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$locationText | Today',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '65% Hum',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                '12 km/h',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'Rain 10%',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? AppColors.primary
              : const Color(0xFFA7F3D0),
          width: 1.5,
        ),
        boxShadow: _searchQuery.isNotEmpty
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search crops, land, tractors, services...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primaryDark,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSearchResultsView() {
    final results = _searchResults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Search Results (${results.length})',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (results.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 54,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No results found for "$_searchQuery"',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Try searching for "Wheat", "Tractor", "Land", "Doctor", or "Calendar".',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = results[index];
              return InkWell(
                onTap: () => _onNavigateItem(item),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: AppColors.primaryDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item['title'] as String,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: Text(
                                    item['category'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item['subtitle'] as String,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {
        'title': 'AI Assistant',
        'subtitle': 'Smart Advisor',
        'icon': Icons.auto_awesome,
        'action': () {
          if (widget.onSwitchTab != null) {
            widget.onSwitchTab!(2);
          } else {
            Navigator.pushNamed(context, '/ai-chat');
          }
        },
      },
      {
        'title': 'Crop Advisor',
        'subtitle': 'Yield Planning',
        'icon': Icons.eco,
        'action': () => Navigator.pushNamed(context, '/crop_advisor'),
      },
      {
        'title': 'Land Market',
        'subtitle': 'Buy & Sell Land',
        'icon': Icons.flag,
        'action': () => Navigator.pushNamed(context, '/land_marketplace'),
      },
      {
        'title': 'Tractor Hire',
        'subtitle': 'Rent Equipment',
        'icon': Icons.agriculture,
        'action': () => Navigator.pushNamed(context, '/tractor_hire'),
      },
      {
        'title': 'My Farm',
        'subtitle': 'Plot Monitoring',
        'icon': Icons.local_florist,
        'action': () {
          if (widget.onSwitchTab != null) {
            widget.onSwitchTab!(1);
          } else {
            Navigator.pushNamed(context, '/my-farm');
          }
        },
      },
      {
        'title': 'Crop Calendar',
        'subtitle': 'Task Scheduler',
        'icon': Icons.calendar_month,
        'action': () => Navigator.pushNamed(context, '/crop_calendar'),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.1,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final item = services[index];
        return InkWell(
          onTap: item['action'] as VoidCallback,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: AppColors.primaryDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['title'] as String,
                        style: AppTypography.titleSmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['subtitle'] as String,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayTasksCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Farming Tasks :",
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Water Cotton Field (Plot A) |  Spray Fertilizer',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
