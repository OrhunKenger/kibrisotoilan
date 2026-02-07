import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/cyprus_cities.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/error_state_widget.dart';

import 'my_listings_page.dart';
import 'password_change_page.dart'; // Assuming this page exists for password change

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _taxNumberController;
  late final TextEditingController _landlinePhoneController;
  late final TextEditingController _addressDetailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _mapsUrlController;

  String? _selectedCity;
  String? _selectedDistrict;
  bool _isPhoneVisible = true;

  // Track initial values to enable/disable save button
  UserEntity? _initialUser;
  bool _hasChanges = false;
  bool _isFormVisible = false; // New state to toggle form visibility
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(const GetUserProfileEvent());

    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _companyNameController = TextEditingController();
    _taxNumberController = TextEditingController();
    _landlinePhoneController = TextEditingController();
    _addressDetailController = TextEditingController();
    _websiteController = TextEditingController();
    _mapsUrlController = TextEditingController();

    // Add listeners to detect changes
    _fullNameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _bioController.addListener(_checkForChanges);
    _companyNameController.addListener(_checkForChanges);
    _taxNumberController.addListener(_checkForChanges);
    _landlinePhoneController.addListener(_checkForChanges);
    _addressDetailController.addListener(_checkForChanges);
    _websiteController.addListener(_checkForChanges);
    _mapsUrlController.addListener(_checkForChanges);
  }

  void _initializeControllers(UserEntity user) {
    _initialUser = user; // Store initial user state
    _fullNameController.text = user.fullName ?? '';
    _emailController.text = user.email;
    _phoneController.text = user.phoneNumber ?? '';
    _bioController.text = user.bio ?? '';
    _companyNameController.text = user.companyName ?? '';
    _taxNumberController.text = user.taxNumber ?? '';
    _landlinePhoneController.text = user.landlinePhone ?? '';
    _addressDetailController.text = user.addressDetail ?? '';
    _websiteController.text = user.website ?? '';
    _mapsUrlController.text = user.mapsUrl ?? '';
    _selectedCity = (user.city != null && CyprusCities.cities.contains(user.city)) ? user.city : null;
    _selectedDistrict = (user.district != null && _selectedCity != null &&
        (CyprusCities.districts[_selectedCity!] ?? []).contains(user.district)) ? user.district : null;
    _isPhoneVisible = user.isPhoneVisible ?? true;
    _isInitialized = true;
    _checkForChanges(); // Initial check
  }

  void _checkForChanges() {
    // Guard: Don't check if not initialized yet
    if (!_isInitialized || _initialUser == null) return;

    final currentUser = _initialUser!;
    bool changesDetected = false;

    if (_fullNameController.text.trim() != (currentUser.fullName ?? '')) changesDetected = true;
    if (_emailController.text.trim() != currentUser.email) changesDetected = true;
    if (_phoneController.text.trim() != (currentUser.phoneNumber ?? '')) changesDetected = true;
    if (_bioController.text.trim() != (currentUser.bio ?? '')) changesDetected = true;
    if (_companyNameController.text.trim() != (currentUser.companyName ?? '')) changesDetected = true;
    if (_taxNumberController.text.trim() != (currentUser.taxNumber ?? '')) changesDetected = true;
    if (_landlinePhoneController.text.trim() != (currentUser.landlinePhone ?? '')) changesDetected = true;
    if (_addressDetailController.text.trim() != (currentUser.addressDetail ?? '')) changesDetected = true;
    if (_websiteController.text.trim() != (currentUser.website ?? '')) changesDetected = true;
    if (_mapsUrlController.text.trim() != (currentUser.mapsUrl ?? '')) changesDetected = true;
    if (_selectedCity != currentUser.city) changesDetected = true;
    if (_selectedDistrict != currentUser.district) changesDetected = true;
    if (_isPhoneVisible != (currentUser.isPhoneVisible ?? true)) changesDetected = true;

    if (mounted) {
      setState(() {
        _hasChanges = changesDetected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Çıkış Yap'),
                  content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Vazgeç'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<AuthBloc>().add(const LogoutRequested());
                      },
                      child: const Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil güncellendi'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<UserBloc>().add(const GetUserProfileEvent()); // Reload profile after update
          } else if (state is UserLoaded) {
            // Initialize controllers when user data is loaded
            _initializeControllers(state.user);
          } else if (state is UserUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is UserDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hesabınız başarıyla silindi. Hoşçakalın!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<AuthBloc>().add(const LogoutRequested());
          } else if (state is UserVerificationRequired) {
            _showVerificationDialog(context, state.codeType, state.data);
          }
        },
        buildWhen: (_, current) =>
            current is UserLoading ||
            current is UserLoaded ||
            current is UserError ||
            current is UserUpdating,
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            final user = state.user;
            final isLoading = state is UserUpdating;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 24),
                  _buildStats(user),
                  const SizedBox(height: 24),
                  _buildDashboardMenu(user, isLoading),
                  if (_isFormVisible) ...[
                    const SizedBox(height: 24),
                    _buildEditForm(user, isLoading),
                  ],
                  const SizedBox(height: 24),
                  _buildFooter(user, isLoading),
                ],
              ),
            );
          } else if (state is UserError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<UserBloc>().add(const GetUserProfileEvent()),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // Helper Methods for UI Sections
  Widget _buildHeader(UserEntity user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surfaceLight,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(user.fullName ?? 'İsim Bilgisi Yok', style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(user.email, style: AppTextStyles.bodySecondary),
          if (user.isVerified) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user, color: AppColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text('Doğrulanmış Hesap', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats(UserEntity user) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Aktif İlan', user.activeAdsCount.toString()),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.divider),
            _buildStatItem('Görüntülenme', user.totalViewsCount.toString()),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.divider),
            _buildStatItem('Favori', user.favoritesCount.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildDashboardMenu(UserEntity user, bool isLoading) {
    return Column(
      children: [
        _buildMenuTile(
          icon: Icons.list,
          label: 'İlanlarım',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<UserBloc>()),
                    BlocProvider.value(value: context.read<CarBloc>()),
                  ],
                  child: const MyListingsPage(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildMenuTile(
          icon: Icons.favorite_border,
          label: 'Favorilerim',
          onTap: () {
            // Navigate to favorites page
            // Navigator.of(context).push(MaterialPageRoute(builder: (_) => FavoritesPage()));
          },
        ),
        const SizedBox(height: 8),
        _buildMenuTile(
          icon: Icons.person_outline,
          label: 'Kişisel Bilgiler',
          onTap: () {
            setState(() {
              _isFormVisible = !_isFormVisible;
            });
          },
        ),
        const SizedBox(height: 8),
        _buildMenuTile(
          icon: Icons.lock_outline,
          label: 'Şifre Değiştir',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BlocProvider.value(
                value: context.read<UserBloc>(),
                child: PasswordChangePage(),
              )),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      color: AppColors.surface,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: AppTextStyles.body),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textHint),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildEditForm(UserEntity user, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editable Fields
          AppTextField(
            controller: _fullNameController,
            label: 'Ad Soyad',
            prefixIcon: Icons.person,
            onChanged: (_) => _checkForChanges(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: Icons.email,
            readOnly: true, // Email is read-only, change via dialog
            suffixIcon: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEmailChangeDialog(context, user.email);
              },
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _phoneController,
            label: 'Telefon',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            readOnly: true, // Phone is read-only, change via dialog
            suffixIcon: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showPhoneChangeDialog(context, user.phoneNumber);
              },
            ),
          ),
          const SizedBox(height: 12),
          AppDropdown<String>(
            label: 'Şehir',
            value: _selectedCity,
            items: CyprusCities.cities,
            onChanged: (v) {
              setState(() {
                _selectedCity = v;
                _selectedDistrict = null;
              });
              _checkForChanges();
            },
            itemLabel: (e) => e,
            prefixIcon: Icons.location_city,
          ),
          const SizedBox(height: 12),
          AppDropdown<String>(
            label: 'İlçe',
            value: _selectedDistrict,
            items: _selectedCity != null
                ? CyprusCities.districts[_selectedCity!] ?? []
                : [],
            onChanged: _selectedCity == null
                ? (_) {}
                : (v) {
              setState(() => _selectedDistrict = v);
              _checkForChanges();
            },
            itemLabel: (e) => e,
            prefixIcon: Icons.location_on,
            nullOptionLabel: _selectedCity == null ? 'Önce şehir seçiniz' : 'İlçe Seçiniz',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _bioController,
            label: 'Hakkında',
            prefixIcon: Icons.info_outline,
            maxLines: 3,
            onChanged: (_) => _checkForChanges(),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: SwitchListTile(
              title: const Text('Telefon Görünsün'),
              subtitle: Text(_isPhoneVisible ? 'Herkes görebilir' : 'Sadece sen'),
              value: _isPhoneVisible,
              onChanged: (v) {
                setState(() => _isPhoneVisible = v);
                _checkForChanges();
              },
              activeTrackColor: AppColors.primary,
            ),
          ),

          // Corporate fields
          if (user.accountType == AccountType.corporate) ...[
            const SizedBox(height: 24),
            const Text('Kurumsal Bilgiler',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 12),
            AppTextField(
              controller: _companyNameController,
              label: 'Şirket Adı',
              prefixIcon: Icons.business,
              onChanged: (_) => _checkForChanges(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _taxNumberController,
              label: 'Vergi Numarası',
              prefixIcon: Icons.numbers,
              onChanged: (_) => _checkForChanges(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _landlinePhoneController,
              label: 'Sabit Telefon',
              prefixIcon: Icons.phone_callback,
              keyboardType: TextInputType.phone,
              onChanged: (_) => _checkForChanges(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _addressDetailController,
              label: 'Adres',
              prefixIcon: Icons.home,
              maxLines: 2,
              onChanged: (_) => _checkForChanges(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _websiteController,
              label: 'Web Sitesi',
              prefixIcon: Icons.web,
              keyboardType: TextInputType.url,
              onChanged: (_) => _checkForChanges(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _mapsUrlController,
              label: 'Haritalar URL',
              prefixIcon: Icons.map,
              keyboardType: TextInputType.url,
              onChanged: (_) => _checkForChanges(),
            ),
          ],

          const SizedBox(height: 32),
          AppButton(
            label: 'Kaydet',
            isLoading: isLoading,
            onPressed: _hasChanges && !isLoading ? _submit : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(UserEntity user, bool isLoading) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.logout, color: AppColors.error),
          title: Text('Çıkış Yap', style: AppTextStyles.body.copyWith(color: AppColors.error)),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Çıkış Yap'),
                content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Vazgeç'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                    child: const Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
        ),
        if (user.role != 'admin')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: isLoading ? null : () => _confirmDeleteAccount(context),
              child: Text(
                'Hesabı Sil',
                style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              ),
            ),
          ),
      ],
    );
  }

  // --- Dialogs ---
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hesabı Sil'),
        content: const Text(
            'Hesabınızı sildiğinizde, ilanlarınız 30 gün boyunca askıya alınacak ve hesabınız kalıcı olarak silinecektir. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<UserBloc>().add(const UserDeleteEvent());
            },
            child: const Text('Hesabı Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showVerificationDialog(BuildContext context, String? codeType, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${codeType ?? "Doğrulama"} İşlemi'),
        content: Text('Lütfen ${data?['new_email'] ?? data?['new_phone_number'] ?? ""} adresine gönderilen kodu giriniz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showEmailChangeDialog(BuildContext context, String? currentEmail) {
    final TextEditingController controller = TextEditingController(text: currentEmail);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-posta Değiştir'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Yeni E-posta Adresi'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Placeholder for future logic
              Navigator.pop(context);
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showPhoneChangeDialog(BuildContext context, String? currentPhone) {
    final TextEditingController controller = TextEditingController(text: currentPhone);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Telefon Değiştir'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Yeni Telefon Numarası'),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Placeholder for future logic
              Navigator.pop(context);
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }





  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_initialUser == null) return;

    final user = _initialUser!;
    final data = <String, dynamic>{};
    bool isChanged = false;

    if (_fullNameController.text.trim() != (user.fullName ?? '')) {
      data['full_name'] = _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim();
      isChanged = true;
    }
    // For email, use new_email for sensitive update
    if (_emailController.text.trim() != user.email) {
      data['new_email'] = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
      isChanged = true;
    }
    // For phone number, use new_phone_number for sensitive update
    if (_phoneController.text.trim() != (user.phoneNumber ?? '')) {
      data['new_phone_number'] = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
      isChanged = true;
    }
    if (_selectedCity != user.city) {
      data['city'] = _selectedCity;
      isChanged = true;
    }
    if (_selectedDistrict != user.district) {
      data['district'] = _selectedDistrict;
      isChanged = true;
    }
    if (_bioController.text.trim() != (user.bio ?? '')) {
      data['bio'] = _bioController.text.trim().isEmpty ? null : _bioController.text.trim();
      isChanged = true;
    }
    if (_isPhoneVisible != (user.isPhoneVisible ?? true)) {
      data['is_phone_visible'] = _isPhoneVisible;
      isChanged = true;
    }

    // Corporate fields
    if (user.accountType == AccountType.corporate) {
      if (_companyNameController.text.trim() != (user.companyName ?? '')) {
        data['company_name'] = _companyNameController.text.trim().isEmpty ? null : _companyNameController.text.trim();
        isChanged = true;
      }
      if (_taxNumberController.text.trim() != (user.taxNumber ?? '')) {
        data['tax_number'] = _taxNumberController.text.trim().isEmpty ? null : _taxNumberController.text.trim();
        isChanged = true;
      }
      if (_landlinePhoneController.text.trim() != (user.landlinePhone ?? '')) {
        data['landline_phone'] = _landlinePhoneController.text.trim().isEmpty ? null : _landlinePhoneController.text.trim();
        isChanged = true;
      }
      if (_addressDetailController.text.trim() != (user.addressDetail ?? '')) {
        data['address_detail'] = _addressDetailController.text.trim().isEmpty ? null : _addressDetailController.text.trim();
        isChanged = true;
      }
      if (_websiteController.text.trim() != (user.website ?? '')) {
        data['website'] = _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim();
        isChanged = true;
      }
      if (_mapsUrlController.text.trim() != (user.mapsUrl ?? '')) {
        data['maps_url'] = _mapsUrlController.text.trim().isEmpty ? null : _mapsUrlController.text.trim();
        isChanged = true;
      }
    }

    if (!isChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hiçbir değişiklik yapılmadı.'), backgroundColor: AppColors.info),
      );
      return;
    }

    context.read<UserBloc>().add(UpdateUserProfileEvent(data: data));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _companyNameController.dispose();
    _taxNumberController.dispose();
    _landlinePhoneController.dispose();
    _addressDetailController.dispose();
    _websiteController.dispose();
    _mapsUrlController.dispose();
    super.dispose();
  }
}