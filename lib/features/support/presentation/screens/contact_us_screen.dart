import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/support_providers.dart';

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedSubject = 'General Inquiry';

  final List<String> _subjects = [
    'General Inquiry',
    'Recipe & Cooking Question',
    'Recipe Submission Feedback',
    'Report an App Bug / Issue',
    'Feature Suggestion',
    'Culinary Partnership / Press',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    final success = await ref.read(contactFormNotifierProvider.notifier).submitInquiry(
      name: name,
      email: email,
      subject: _selectedSubject,
      message: message,
    );

    if (!mounted) return;

    if (success) {
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      _showSuccessDialog();
    } else {
      final errorMsg = ref.read(contactFormNotifierProvider).errorMessage ?? 'Submission failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
      );
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
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
                color: AppColors.vegGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.vegGreen, size: 38),
            ),
            const SizedBox(height: 16),
            const Text(
              'Message Sent Successfully',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Thank you for reaching out to Food CHART! Our culinary and technical support team will review your message and reply back shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageAsync = ref.watch(supportPageProvider('contact-us'));
    final formState = ref.watch(contactFormNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Info',
            onPressed: () => ref.invalidate(supportPageProvider('contact-us')),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(supportPageProvider('contact-us')),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Hero Intro Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1E1E), const Color(0xFF141414)]
                      : [Colors.white, const Color(0xFFFFF6F4)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.headset_mic_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Food CHART Support Desk',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We are always excited to hear from you! Have feedback, questions about authentic recipes, or need assistance? Reach out via direct channels or leave us a message below.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Direct Contact Cards
            pageAsync.when(
              data: (page) {
                final meta = page.meta;
                final email = meta['support_email'] ?? 'support@cookmate.app';
                final phone = meta['phone'] ?? '+91 (80) 4567-8900';
                final hours = meta['hours'] ?? 'Mon - Sat: 9 AM - 6 PM IST';
                final address = meta['address'] ?? 'Bengaluru, Karnataka, India';

                return Column(
                  children: [
                    _buildContactTile(
                      icon: Icons.email_rounded,
                      title: 'Support Email',
                      value: email,
                      sub: 'Expect response within 24 hours',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildContactTile(
                      icon: Icons.phone_rounded,
                      title: 'Phone Helpline',
                      value: phone,
                      sub: hours,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildContactTile(
                      icon: Icons.location_on_rounded,
                      title: 'Culinary Labs',
                      value: address,
                      sub: 'Western Ghats Heritage Research Unit',
                      isDark: isDark,
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 28),

            // Send Message Form Header
            const Text(
              'SEND US A MESSAGE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBackground : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter your email';
                        if (!val.contains('@') || !val.contains('.')) return 'Please enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subject Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSubject,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Subject / Category',
                        prefixIcon: Icon(Icons.topic_outlined, size: 20),
                      ),
                      dropdownColor: isDark ? AppColors.cardBackground : Colors.white,
                      items: _subjects.map((sub) {
                        return DropdownMenuItem(
                          value: sub,
                          child: Text(
                            sub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13.5),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSubject = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Message Body
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Message Body',
                        hintText: 'Describe your query or feedback in detail...',
                        alignLabelWithHint: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter a message';
                        if (val.trim().length < 10) return 'Message must be at least 10 characters long';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: formState.isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: formState.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Send Message',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String value,
    required String sub,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white60 : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
