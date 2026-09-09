import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/rating_remote_datasource.dart';
import '../../services/rating_service.dart';

/// Screen where users can submit detailed feedback and ratings (especially 1, 2, or 3 stars)
/// to help the CookMate team improve the application.
class RateUsScreen extends StatefulWidget {
  const RateUsScreen({
    super.key,
    this.initialStars = 3,
    this.httpClient,
    this.remoteDataSource,
  });

  final int initialStars;
  final http.Client? httpClient;
  final RatingRemoteDataSource? remoteDataSource;

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  late int _selectedStars;
  String _selectedCategory = 'App Performance';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'App Performance',
    'Recipe Instructions',
    'Missing Features',
    'App Bug / Error',
    'Design & Navigation',
    'Other Suggestions',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStars = widget.initialStars.clamp(1, 5);
    _loadUserDisplayName();
  }

  Future<void> _loadUserDisplayName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString(AppConstants.keyUserDisplayName);
      if (savedName != null && savedName.trim().isNotEmpty && mounted) {
        _nameController.text = savedName.trim();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _getStarLabel(int stars) {
    switch (stars) {
      case 1:
        return '1 Star • Needs major improvement';
      case 2:
        return '2 Stars • Could be better';
      case 3:
        return '3 Stars • Average experience';
      case 4:
        return '4 Stars • Good experience';
      case 5:
        return '5 Stars • Loved it!';
      default:
        return '$stars Stars';
    }
  }

  Color _getStarColor(int stars) {
    if (stars <= 1) return const Color(0xFFE50914);
    if (stars == 2) return const Color(0xFFFF9800);
    if (stars == 3) return const Color(0xFFFFB300);
    return const Color(0xFF4CAF50);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final feedback = _feedbackController.text.trim();
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Food CHART User';
    final email = _emailController.text.trim();

    String deviceInfo = 'Unknown Device';
    try {
      deviceInfo = '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    } catch (_) {}

    final dataSource = widget.remoteDataSource ?? RatingRemoteDataSourceImpl(client: widget.httpClient);
    final isSuccess = await dataSource.submitRating(
      stars: _selectedStars,
      category: _selectedCategory,
      feedbackText: feedback,
      userName: name,
      userEmail: email.isNotEmpty ? email : null,
      deviceInfo: deviceInfo,
      appVersion: '2.0.0',
    );

    // Always record rating submission in local RatingService
    try {
      await RatingService.instance.recordRatingSubmitted(_selectedStars);
    } catch (_) {}

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (isSuccess) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit feedback. Please check your network and try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank You for Your Feedback! ❤️',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your honest thoughts help the Food CHART culinary and engineering team make the app significantly better with every update.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('rate_us_thank_you_button'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (mounted) {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Recipes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.cardBackground : Colors.white;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final starColor = _getStarColor(_selectedStars);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Rate Food CHART',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Banner Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🍳', style: TextStyle(fontSize: 30)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Help Us Improve Food CHART',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'We value your honest feedback. Tell us what worked and where we can do better.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),

                      // Interactive Stars Row
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starNum = index + 1;
                            final isFilled = starNum <= _selectedStars;
                            return GestureDetector(
                              key: Key('rate_us_star_$starNum'),
                              onTap: () {
                                setState(() {
                                  _selectedStars = starNum;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: AnimatedScale(
                                  scale: isFilled ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutBack,
                                  child: Icon(
                                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                    size: 36,
                                    color: isFilled ? starColor : (isDark ? Colors.white30 : Colors.black26),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Star count badge & explanation
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: starColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: starColor.withValues(alpha: 0.3)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _getStarLabel(_selectedStars),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: starColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Category Selection
                Text(
                  'What would you like to improve?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return ChoiceChip(
                      key: Key('category_${category.replaceAll(' ', '_')}'),
                      label: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: surfaceColor,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : borderColor,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = category);
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // Feedback Text Field
                Text(
                  'Your Detailed Feedback',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('rate_us_feedback_input'),
                  controller: _feedbackController,
                  maxLines: 5,
                  minLines: 3,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe your experience, what could be improved, or any issue you encountered...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : AppColors.lightTextMuted,
                    ),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please write a brief feedback message.';
                    }
                    if (val.trim().length < 5) {
                      return 'Feedback must be at least 5 characters.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Name & Email (Optional)
                Text(
                  'Contact Information (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('rate_us_name_input'),
                  controller: _nameController,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    hintText: 'e.g. Rahul Sharma',
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('rate_us_email_input'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Optional - if you want our team to reply',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('rate_us_submit_button'),
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Feedback',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20 + MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
