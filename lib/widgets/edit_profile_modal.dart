import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopLocationController = TextEditingController();

  String? _selectedAvatarUrl;
  bool _isUploading = false;

  final List<String> _sampleAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
  ];

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phone;
      _emailController.text = user.email;
      _selectedAvatarUrl = user.avatarUrl;

      if (user is BarberUser) {
        _shopNameController.text = user.shopName;
        _shopLocationController.text = user.shopLocation;
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _shopNameController.dispose();
    _shopLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isUploading = true);
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/png;base64,${base64Encode(bytes)}';
        setState(() {
          _selectedAvatarUrl = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  ImageProvider? _getAvatarImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:image')) {
      try {
        final base64Str = url.split(',').last;
        return MemoryImage(base64Decode(base64Str));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(url);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user is BarberUser) {
      _authService.updateBarberProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        shopName: _shopNameController.text.trim(),
        shopLocation: _shopLocationController.text.trim(),
        avatarUrl: _selectedAvatarUrl,
      );
    } else if (user is CustomerUser) {
      _authService.updateCustomerProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        avatarUrl: _selectedAvatarUrl,
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isBarber = user is BarberUser;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_outline_rounded, color: AppTheme.primary, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Edit Profile Information',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Divider(color: AppTheme.borderColor, height: 24),

              // Avatar Photo Selector
              const Text(
                'Profile Photo / Avatar',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Main Avatar Circle with Edit Badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                        backgroundImage: _getAvatarImageProvider(_selectedAvatarUrl),
                        child: (_selectedAvatarUrl == null || _selectedAvatarUrl!.isEmpty) && !_isUploading
                            ? const Icon(Icons.person, color: AppTheme.primary, size: 38)
                            : null,
                      ),
                      if (_isUploading)
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.black45,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Gallery & Camera Buttons
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library_rounded, size: 16),
                                label: const Text('Gallery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt_rounded, size: 16),
                                label: const Text('Camera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  side: const BorderSide(color: AppTheme.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Demo Preset Avatars Sub-selector
                        const Text(
                          'Or select a demo avatar:',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _sampleAvatars.map((url) {
                              final isSelected = _selectedAvatarUrl == url;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedAvatarUrl = url),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primary : AppTheme.borderColor,
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(url),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'First Name',
                      hint: 'Your first name',
                      controller: _firstNameController,
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Last Name',
                      hint: 'Your last name',
                      controller: _lastNameController,
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              CustomTextField(
                label: 'Phone Number',
                hint: '+1 (555) 000-0000',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                label: 'Email Address',
                hint: 'your.email@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),

              if (isBarber) ...[
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Barbershop / Studio Name',
                  hint: 'e.g. Elite Barber Shop',
                  controller: _shopNameController,
                  prefixIcon: Icons.storefront_outlined,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Location / Address',
                  hint: 'e.g. 45 Main St, Suite 102',
                  controller: _shopLocationController,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
              ],

              const SizedBox(height: 24),

              CustomButton(
                text: 'Save Changes',
                icon: Icons.save_rounded,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
