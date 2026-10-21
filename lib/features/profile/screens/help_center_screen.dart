import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/khedut_app_bar.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _queryController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Account & Profile',
    'Land Records',
    'Crops & Farming',
    'Tractor & Machinery',
    'Payments & Bookings',
    'Notifications',
    'App Settings',
  ];

  final List<Map<String, String>> _faqs = [
    {
      'category': 'Account & Profile',
      'q': 'How can I update my farmer profile?',
      'a':
          'To update your profile, go to the Profile tab from the bottom navigation and tap "Edit Farmer Profile". You can modify your full name, father\'s name, contact number, village, taluka, district, and land acreage. Tap "Save Profile Changes" to update your details across the app.',
    },
    {
      'category': 'Land Records',
      'q': 'How can I add or manage land records?',
      'a':
          'Navigate to your Profile tab and select "Land Records & 7/12 Documents". Here you can view your official revenue land ownership details verified via Gujarat\'s AnyRoR portal, including your Khata number, Survey/Block number, total land area in acres, soil classification, and irrigation source.',
    },
    {
      'category': 'Crops & Farming',
      'q': 'How can I add a crop?',
      'a':
          'Open the "My Farm" tab from the bottom navigation and tap the "+ Add Crop" button. Select your crop (such as Cotton, Wheat, Groundnut, or Cumin), assign it to a plot, choose your sowing date, and select your irrigation system. This will automatically generate a tailored crop calendar and irrigation schedule.',
    },
    {
      'category': 'Crops & Farming',
      'q': 'How can I check crop recommendations?',
      'a':
          'Go to the "AI Assistant" section from Home or bottom navigation, then select "Smart Crop Advisor". Enter your soil type, water availability, and season (Kharif, Rabi, or Zaid). Our agronomy engine will recommend high-yield crop varieties and optimal sowing windows suited for Gujarat soil.',
    },
    {
      'category': 'Tractor & Machinery',
      'q': 'How can I book a tractor or farm machinery?',
      'a':
          'Open "Tractor & Machinery Rentals" from the Home screen or Farmer Profile. Browse through available tractors, rotavators, cultivators, and harvesters. Tap "Book Now" or "View Details", select your booking date, start time, required duration, and delivery plot, then tap "Confirm Booking".',
    },
    {
      'category': 'Payments & Bookings',
      'q': 'How can I cancel a machinery booking?',
      'a':
          'Go to the "Tractor & Machinery Rentals" screen and tap the "My Bookings" tab. Find the booking you wish to cancel and tap the "Cancel Booking" button. Confirm the cancellation prompt. You will not be charged any cancellation fee if cancelled prior to dispatch.',
    },
    {
      'category': 'Payments & Bookings',
      'q': 'How can I manage farm expenses?',
      'a':
          'From the "My Farm" screen or Profile page, tap "Farm Expenses & Accounts". You can view total season spending, add new expenses (seeds, fertilizer, labor, machinery hire, pesticide), filter by category, and delete or edit entries. Tractor rental bookings can also be added directly to your expense ledger!',
    },
    {
      'category': 'Notifications',
      'q': 'How can I receive notifications and alerts?',
      'a':
          'Tap "Notifications & Alerts" in the Profile or Settings screen. KhedutRise sends real-time alerts for local mandi prices (Rajkot, Gondal, Jasdan), weather warnings (rain and cyclone alerts), pest advisories, and machinery booking status.',
    },
    {
      'category': 'Crops & Farming',
      'q': 'How do I use the AI Leaf Disease Scanner?',
      'a':
          'Go to the AI Assistant tab and tap "Scan Leaf" or "Select Photo". Position your camera 15-20cm from the infected leaf in clear daylight. Our AI analyzes the visual symptoms within 2 seconds and provides recommended treatments and pesticide dosage.',
    },
    {
      'category': 'App Settings',
      'q': 'How do I change the app language or offline settings?',
      'a':
          'Visit "App Settings" under Settings & Kisan Support in your Profile tab. You can toggle between English and Gujarati, enable Dark/Light theme, and manage offline data caching for uninterrupted field usage.',
    },
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Fallback try without mode
        await launchUrl(uri);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dialer opened for $phoneNumber'),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _submitQuery() {
    if (_queryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your question before submitting.'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Query Submitted',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Thank you! A Krishi Vigyan Kendra (KVK) officer will respond within 24 hours via phone/SMS.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              _queryController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Your query has been recorded. Ticket #KVK-8492.',
                  ),
                  backgroundColor: AppColors.primaryDark,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> get _filteredFaqs {
    return _faqs.where((faq) {
      final matchCategory =
          _selectedCategory == 'All' || faq['category'] == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchSearch =
          query.isEmpty ||
          faq['q']!.toLowerCase().contains(query) ||
          faq['a']!.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _filteredFaqs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KhedutAppBar(
        title: 'Kisan Help Center',
        subtitle: '24x7 Farmer Support & Guidance',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Helpline Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone_in_talk,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kisan Call Center (Toll Free)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Govt. Agricultural Expert Support • 24x7',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            '1800-180-1551',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E3A8A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text(
                            'Call Now',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          onPressed: () => _makePhoneCall('1800-180-1551'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search help questions, land records, tractor...',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primaryDark,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  fillColor: Colors.grey.shade50,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Help Categories Section
              Text(
                'Help Categories',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      selectedColor: AppColors.primaryDark,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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

              const SizedBox(height: 20),

              // Frequently Asked Questions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${filteredFaqs.length} FAQs',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (filteredFaqs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No questions found matching your search',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredFaqs.map(
                  (faq) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: AppColors.primaryDark,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        faq['q']!,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: Text(
                            faq['a']!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 22),

              // Support & Direct Contact Channels
              Text(
                'Farmer Support & Contact Channels',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.support_agent,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      title: const Text(
                        'Krishi Vigyan Kendra (KVK)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Agronomy specialists • Rajkot rural circle',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                        icon: const Icon(Icons.call, size: 14),
                        label: const Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () => _makePhoneCall('+91 281 278 4500'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFDCFCE7),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      title: const Text(
                        'Khedut WhatsApp Helpdesk',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        '+91 94282 15510 • Mon-Sat 9AM-6PM',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF16A34A)),
                          foregroundColor: const Color(0xFF16A34A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                        icon: const Icon(Icons.phone, size: 14),
                        label: const Text(
                          'Dial',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () => _makePhoneCall('+91 94282 15510'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFEF3C7),
                        child: Icon(
                          Icons.mail_outline,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      title: const Text(
                        'Farmer Support Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'support@khedutrise.in • Quick resolution',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.copy,
                          size: 18,
                          color: AppColors.primaryDark,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Support email copied: support@khedutrise.in',
                              ),
                              backgroundColor: AppColors.primaryDark,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Contact Form
              Text(
                'Ask an Agricultural Officer',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Have a specific question about crops, fertilizers, or machinery? Post it below.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _queryController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your farming problem or question here...',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  fillColor: Colors.grey.shade50,
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send, size: 16),
                label: const Text(
                  'Submit Question',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: _submitQuery,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
