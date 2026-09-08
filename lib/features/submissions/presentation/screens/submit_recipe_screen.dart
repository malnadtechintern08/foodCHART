import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../rating/services/rating_service.dart';
import '../providers/submission_providers.dart';

class SubmitRecipeScreen extends ConsumerStatefulWidget {
  final int? editSubmissionId;

  const SubmitRecipeScreen({super.key, this.editSubmissionId});

  @override
  ConsumerState<SubmitRecipeScreen> createState() => _SubmitRecipeScreenState();
}

class _SubmitRecipeScreenState extends ConsumerState<SubmitRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '20');
  final _cookTimeController = TextEditingController(text: '30');
  final _servingsController = TextEditingController(text: '4');
  final _cuisineController = TextEditingController(text: 'Malnad');
  final _notesController = TextEditingController();
  final _contributorNameController = TextEditingController();
  final _hashtagController = TextEditingController();

  String _selectedCategoryId = 'cat_malnad';
  String _selectedDifficulty = 'Medium';
  bool _isVegetarian = false;

  // Photo
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  // Dynamic Ingredients & Steps
  final List<Map<String, TextEditingController>> _ingredientControllers = [];
  final List<Map<String, TextEditingController>> _stepControllers = [];

  // Hashtags
  final List<String> _hashtags = [];

  // Publication Permission Consent (STRICTLY UNCHECKED BY DEFAULT)
  bool _allowPublication = false;
  bool _showAuthorName = false;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserDisplayName();
    _initDefaultFields();

    if (widget.editSubmissionId != null) {
      _loadExistingSubmission(widget.editSubmissionId!);
    }
  }

  Future<void> _loadUserDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(AppConstants.keyUserDisplayName);
    if (name != null && name.isNotEmpty) {
      _contributorNameController.text = name;
    }
  }

  void _initDefaultFields() {
    _addIngredient('Chicken / Paneer', '500', 'g');
    _addIngredient('Onion', '2', 'medium');
    _addIngredient('Spices & Herbs', '1', 'tbsp');

    _addStep('Prepare and clean all fresh ingredients.', 5);
    _addStep('Heat pan and sauté aromatics until fragrant.', 10);
    _addStep('Add main ingredients and simmer over balanced heat.', 20);

    _hashtags.addAll(['malnad', 'homemade']);
  }

  Future<void> _loadExistingSubmission(int id) async {
    try {
      final sub = await ref.read(submissionRepositoryProvider).getSubmissionDetails(id);
      setState(() {
        _nameController.text = sub.recipeName;
        _descriptionController.text = sub.description;
        _selectedCategoryId = sub.categoryId;
        _prepTimeController.text = sub.prepTime.toString();
        _cookTimeController.text = sub.cookTime.toString();
        _servingsController.text = sub.servings.toString();
        _selectedDifficulty = sub.difficulty;
        _cuisineController.text = sub.cuisine;
        _isVegetarian = sub.isVegetarian;
        _notesController.text = sub.notes ?? '';
        _allowPublication = sub.allowPublication;
        _showAuthorName = sub.showAuthorName;
        if (sub.authorDisplayName != null) {
          _contributorNameController.text = sub.authorDisplayName!;
        }

        // Replace ingredients
        _ingredientControllers.clear();
        for (final ing in sub.ingredients) {
          _addIngredient(ing.name, ing.quantity, ing.unit);
        }

        // Replace steps
        _stepControllers.clear();
        for (final st in sub.steps) {
          _addStep(st.instruction, (st.timerSeconds / 60).round());
        }

        _hashtags.clear();
        _hashtags.addAll(sub.tags);
      });
    } catch (_) {}
  }

  void _addIngredient([String name = '', String qty = '1', String unit = 'cup']) {
    setState(() {
      _ingredientControllers.add({
        'name': TextEditingController(text: name),
        'quantity': TextEditingController(text: qty),
        'unit': TextEditingController(text: unit),
      });
    });
  }

  void _removeIngredient(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index]['name']?.dispose();
        _ingredientControllers[index]['quantity']?.dispose();
        _ingredientControllers[index]['unit']?.dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addStep([String text = '', int timerMinutes = 0]) {
    setState(() {
      _stepControllers.add({
        'instruction': TextEditingController(text: text),
        'timer': TextEditingController(text: timerMinutes > 0 ? timerMinutes.toString() : ''),
      });
    });
  }

  void _removeStep(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index]['instruction']?.dispose();
        _stepControllers[index]['timer']?.dispose();
        _stepControllers.removeAt(index);
      });
    }
  }

  void _addHashtag(String raw) {
    final clean = raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '').trim();
    if (clean.isNotEmpty && !_hashtags.contains(clean)) {
      setState(() {
        _hashtags.add(clean);
        _hashtagController.clear();
      });
    }
  }

  void _removeHashtag(String tag) {
    setState(() {
      _hashtags.remove(tag);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImagePath = picked.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access photo: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Text('Select Recipe Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.lightTextPrimary)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary)),
                title: const Text('Take a Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library_rounded, color: AppColors.primary)),
                title: const Text('Choose from Photo Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return; // Prevent double taps

    if (!_formKey.currentState!.validate()) return;

    // Validate ingredients
    final ingredientsList = <Map<String, dynamic>>[];
    for (int i = 0; i < _ingredientControllers.length; i++) {
      final name = _ingredientControllers[i]['name']!.text.trim();
      final qty = _ingredientControllers[i]['quantity']!.text.trim();
      final unit = _ingredientControllers[i]['unit']!.text.trim();
      if (name.isNotEmpty) {
        ingredientsList.add({
          'name': name,
          'quantity': qty.isEmpty ? '1' : qty,
          'unit': unit,
          'position': i + 1,
        });
      }
    }

    if (ingredientsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 ingredient.'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Validate steps
    final stepsList = <Map<String, dynamic>>[];
    for (int i = 0; i < _stepControllers.length; i++) {
      final instruction = _stepControllers[i]['instruction']!.text.trim();
      final timerMins = int.tryParse(_stepControllers[i]['timer']!.text.trim()) ?? 0;
      if (instruction.isNotEmpty) {
        stepsList.add({
          'step_number': i + 1,
          'instruction': instruction,
          'timer_seconds': timerMins > 0 ? timerMins * 60 : 0,
        });
      }
    }

    if (stepsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 cooking step.'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Save display name to preferences if provided
    if (_contributorNameController.text.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserDisplayName, _contributorNameController.text.trim());
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(submissionControllerProvider.notifier);
      bool success = false;

      if (widget.editSubmissionId != null) {
        success = await controller.updateSubmission(
          id: widget.editSubmissionId!,
          recipeName: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategoryId,
          prepTime: int.tryParse(_prepTimeController.text.trim()) ?? 15,
          cookTime: int.tryParse(_cookTimeController.text.trim()) ?? 20,
          servings: int.tryParse(_servingsController.text.trim()) ?? 4,
          difficulty: _selectedDifficulty,
          cuisine: _cuisineController.text.trim(),
          foodType: _isVegetarian ? 'Vegetarian' : 'Non-Vegetarian',
          notes: _notesController.text.trim(),
          allowPublication: _allowPublication,
          showAuthorName: _showAuthorName,
          authorDisplayName: _contributorNameController.text.trim(),
          imagePath: _selectedImagePath,
          ingredients: ingredientsList,
          steps: stepsList,
          tags: _hashtags,
        );
      } else {
        success = await controller.submitRecipe(
          recipeName: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategoryId,
          prepTime: int.tryParse(_prepTimeController.text.trim()) ?? 15,
          cookTime: int.tryParse(_cookTimeController.text.trim()) ?? 20,
          servings: int.tryParse(_servingsController.text.trim()) ?? 4,
          difficulty: _selectedDifficulty,
          cuisine: _cuisineController.text.trim(),
          foodType: _isVegetarian ? 'Vegetarian' : 'Non-Vegetarian',
          notes: _notesController.text.trim(),
          allowPublication: _allowPublication,
          showAuthorName: _showAuthorName,
          authorDisplayName: _contributorNameController.text.trim(),
          imagePath: _selectedImagePath,
          ingredients: ingredientsList,
          steps: stepsList,
          tags: _hashtags,
        );
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          _showSuccessDialog();
          // Trigger 1: Show rating popup after a short 1.5s delay following success message
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              RatingService.instance.triggerPostUploadRating(context);
            }
          });
        } else {
          final err = ref.read(submissionControllerProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submission failed: ${err ?? "Please try again"}'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.schedule_send_rounded, color: Colors.amber, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Recipe submitted successfully! 🎉',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your recipe "${_nameController.text.trim()}" has been sent to the Food CHART team for review.',
                style: TextStyle(fontSize: 13.5, color: isDark ? Colors.white70 : AppColors.lightTextSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 16),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Current Status: Pending Review',
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (mounted) {
                    context.go(RoutePaths.mySubmissions);
                    RatingService.instance.triggerBackNavigationRating();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('View My Submissions', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (mounted) {
                    context.go(RoutePaths.home);
                    RatingService.instance.triggerBackNavigationRating();
                  }
                },
                child: const Text('Return to Home', style: TextStyle(color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _cuisineController.dispose();
    _notesController.dispose();
    _contributorNameController.dispose();
    _hashtagController.dispose();

    for (final m in _ingredientControllers) {
      m['name']?.dispose();
      m['quantity']?.dispose();
      m['unit']?.dispose();
    }
    for (final m in _stepControllers) {
      m['instruction']?.dispose();
      m['timer']?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          RatingService.instance.triggerBackNavigationRating();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          widget.editSubmissionId != null ? 'Edit Recipe Submission' : 'Submit Recipe for Review',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Header Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Every community recipe is reviewed by the Food CHART team before publication to maintain culinary quality.',
                      style: TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Photo Selector
            _buildSectionHeader('Recipe Photo', Icons.camera_alt_outlined),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showImagePickerSheet,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
                  image: _selectedImagePath != null
                      ? DecorationImage(image: FileImage(File(_selectedImagePath!)), fit: BoxFit.cover)
                      : null,
                ),
                child: _selectedImagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                            child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(height: 10),
                          const Text('Upload Recipe Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Camera or Gallery (JPEG, PNG, WEBP)', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                              onPressed: _showImagePickerSheet,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Recipe Basics
            _buildSectionHeader('Recipe Basics', Icons.menu_book_outlined),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Recipe Name *', 'e.g. Malnad Chicken Curry'),
              validator: (v) => v == null || v.trim().length < 3 ? 'Enter at least 3 characters' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration('Description *', 'A brief appetizing summary of the dish...'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please provide a description' : null,
            ),
            const SizedBox(height: 14),

            // Category & Dietary
            Row(
              children: [
                Expanded(
                  child: categoriesAsync.when(
                    data: (categories) => DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: _inputDecoration('Category *', ''),
                      items: categories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name, style: const TextStyle(fontSize: 13.5)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategoryId = val);
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => const SizedBox(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDifficulty,
                    decoration: _inputDecoration('Difficulty', ''),
                    items: const [
                      DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDifficulty = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Prep Time, Cook Time, Servings
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Prep (mins)', '15'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _cookTimeController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Cook (mins)', '25'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Servings', '4'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Dietary & Cuisine
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cuisineController,
                    decoration: _inputDecoration('Cuisine', 'e.g. Malnad'),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardBackground : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isVegetarian ? '🌱 Pure Veg' : '🍗 Non-Veg',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _isVegetarian ? AppColors.veg : AppColors.nonVeg,
                        ),
                      ),
                      Switch(
                        value: _isVegetarian,
                        activeThumbColor: AppColors.veg,
                        onChanged: (val) => setState(() => _isVegetarian = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ingredients Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Ingredients (${_ingredientControllers.length})', Icons.egg_outlined),
                TextButton.icon(
                  onPressed: () => _addIngredient(),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Ingredient'),
                ),
              ],
            ),
            ..._ingredientControllers.asMap().entries.map((entry) {
              final idx = entry.key;
              final map = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: map['name'],
                        decoration: _inputDecoration('Ingredient #${idx + 1}', 'e.g. Fresh Coconut'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: map['quantity'],
                        decoration: _inputDecoration('Qty', '1'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: map['unit'],
                        decoration: _inputDecoration('Unit', 'cup'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _removeIngredient(idx),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Cooking Steps Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Cooking Steps (${_stepControllers.length})', Icons.list_alt_rounded),
                TextButton.icon(
                  onPressed: () => _addStep(),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Step'),
                ),
              ],
            ),
            ..._stepControllers.asMap().entries.map((entry) {
              final idx = entry.key;
              final map = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Step ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                          onPressed: () => _removeStep(idx),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: map['instruction'],
                      maxLines: 2,
                      decoration: _inputDecoration('Instruction', 'Describe what to do in this step...'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 160,
                      child: TextFormField(
                        controller: map['timer'],
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Timer (Minutes)', '0'),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Hashtags Section
            _buildSectionHeader('Hashtags (Food Discovery)', Icons.tag_rounded),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hashtagController,
                    decoration: _inputDecoration('Add Hashtag', 'e.g. rice, spicy, malnad'),
                    onFieldSubmitted: (v) => _addHashtag(v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addHashtag(_hashtagController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hashtags.map((tag) {
                return Chip(
                  label: Text('#$tag', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primary),
                  onDeleted: () => _removeHashtag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // =========================================================
            // 2. USER PUBLISHING PERMISSION CONSENT (CRITICAL COMPONENT)
            // =========================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.amber.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _allowPublication ? AppColors.veg.withValues(alpha: 0.6) : Colors.amber.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: _allowPublication ? AppColors.veg : Colors.amber, size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Publishing Permission',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If approved, your recipe may appear publicly in Food CHART and become part of the main Food CHART recipe collection. Your name may be shown as the contributor if you choose.',
                    style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Permission Checkbox (Unchecked by default)
                  CheckboxListTile(
                    value: _allowPublication,
                    onChanged: (val) => setState(() => _allowPublication = val ?? false),
                    activeColor: AppColors.veg,
                    title: const Text(
                      'I give Food CHART permission to publish this recipe in the public Food CHART recipe collection if it is approved by the administrator.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  // Show Author Name Checkbox
                  CheckboxListTile(
                    value: _showAuthorName,
                    onChanged: (val) => setState(() => _showAuthorName = val ?? false),
                    activeColor: AppColors.primary,
                    title: const Text(
                      'Show my name as the recipe contributor',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  if (_showAuthorName) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contributorNameController,
                      decoration: _inputDecoration('Contributor Display Name', 'e.g. Abhishek'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // =========================================================
            // 3. SUBMIT BUTTON
            // =========================================================
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          SizedBox(width: 12),
                          Text('Submitting Recipe for Review...', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Submit Recipe for Review', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontSize: 13),
      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      filled: true,
      fillColor: isDark ? AppColors.cardBackground : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
