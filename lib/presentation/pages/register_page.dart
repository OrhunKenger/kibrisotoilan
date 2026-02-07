import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:mobile/presentation/bloc/auth/auth_event.dart';
import 'package:mobile/presentation/bloc/auth/auth_state.dart';
import 'package:mobile/core/enums/account_type.dart';
import 'package:mobile/core/constants/cyprus_cities.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final AccountType initialAccountType;
  const RegisterPage({super.key, this.initialAccountType = AccountType.individual});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  int _currentStep = 0;

  // Step 1: Account
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;

  // Step 2: Personal
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _selectedCity;
  String? _selectedDistrict;

  // Step 3: Corporate
  final _companyNameController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _landlinePhoneController = TextEditingController();
  final _addressDetailController = TextEditingController();
  final _mapsUrlController = TextEditingController();
  final _websiteController = TextEditingController();

  // Step 4: Profile
  final _profileImageUrlController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isPhoneVisible = true;

  late AccountType _selectedAccountType;

  bool get _isCorporate => _selectedAccountType == AccountType.corporate;

  int get _totalSteps => _isCorporate ? 4 : 3;

  // Map visual step index to logical step index
  int _logicalStep(int visualStep) {
    if (_isCorporate) return visualStep;
    // For individual: step 0,1 map directly, step 2 maps to logical step 3 (profile)
    if (visualStep <= 1) return visualStep;
    return 3; // profile step
  }

  @override
  void initState() {
    super.initState();
    _selectedAccountType = widget.initialAccountType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Kayıt Ol',
          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is RegisterSuccess) {
            _showSuccessDialog(state.message);
          }
        },
        child: Column(
          children: [
            // Step indicator
            _buildStepIndicator(),
            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _buildCurrentStep(),
              ),
            ),
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final stepLabels = _isCorporate
        ? ['Hesap', 'Kişisel', 'Kurumsal', 'Profil']
        : ['Hesap', 'Kişisel', 'Profil'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: AppColors.background,
      child: Row(
        children: List.generate(stepLabels.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.primary
                            : isActive
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.divider,
                        border: isActive
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.black87)
                            : Text(
                                '${index + 1}',
                                style: AppTextStyles.caption.copyWith(
                                  color: isActive ? AppColors.primary : AppColors.textHint,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stepLabels[index],
                      style: AppTextStyles.caption.copyWith(
                        color: isActive ? AppColors.primary : AppColors.textHint,
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    final logicalIdx = _logicalStep(_currentStep);
    switch (logicalIdx) {
      case 0:
        return _buildAccountStep();
      case 1:
        return _buildPersonalStep();
      case 2:
        return _buildCorporateStep();
      case 3:
        return _buildProfileStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Account
  Widget _buildAccountStep() {
    return Form(
      key: _formKeys[0],
      child: _buildCard(
        title: 'Hesap Bilgileri',
        children: [
          _buildTextFormField(
            _emailController,
            'E-posta',
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            maxLength: 100, // ADDED
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen bir e-posta adresi girin';
              }
              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                return 'Geçersiz e-posta formatı';
              }
              if (value.length > 254) {
                return 'E-posta adresi çok uzun';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            _usernameController,
            'Kullanıcı Adı',
            Icons.person_outline,
            maxLength: 100, // ADDED
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen bir kullanıcı adı girin';
              }
              if (value.length < 3 || value.length > 50) {
                return 'Kullanıcı adı 3-50 karakter arasında olmalıdır';
              }
              if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(value)) {
                return 'Harf ile başlamalı, sadece harf, rakam ve alt çizgi içermelidir';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            _passwordController,
            'Şifre',
            Icons.lock_outline,
            obscureText: !_isPasswordVisible,
            maxLength: 100, // ADDED
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textHint,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 8),
          _buildPasswordStrengthIndicator(),
          const SizedBox(height: 16),
          _buildTextFormField(
            _passwordConfirmController,
            'Şifre Tekrar',
            Icons.lock_outline,
            obscureText: !_isPasswordConfirmVisible,
            maxLength: 100, // ADDED
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordConfirmVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textHint,
              ),
              onPressed: () => setState(() => _isPasswordConfirmVisible = !_isPasswordConfirmVisible),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen şifrenizi tekrar girin';
              }
              if (value != _passwordController.text) {
                return 'Şifreler eşleşmiyor';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir şifre girin';
    }
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Şifre en az bir büyük harf içermelidir';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Şifre en az bir küçük harf içermelidir';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Şifre en az bir rakam içermelidir';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=]').hasMatch(value)) {
      return 'Şifre en az bir özel karakter içermelidir';
    }
    return null;
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=]').hasMatch(password)) strength++;

    final colors = [Colors.red, Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green];
    final labels = ['', 'Çok Zayıf', 'Zayıf', 'Orta', 'Güçlü', 'Çok Güçlü'];

    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: index < strength ? colors[strength] : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          labels[strength],
          style: AppTextStyles.caption.copyWith(
            color: colors[strength],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Step 2: Personal
  Widget _buildPersonalStep() {
    final districts = _selectedCity != null
        ? CyprusCities.districts[_selectedCity!] ?? []
        : <String>[];
    return Form(
      key: _formKeys[1],
      child: _buildCard(
        title: 'Kişisel Bilgiler',
        children: [
          _buildTextFormField(_fullNameController, 'Ad Soyad', Icons.badge_outlined, maxLength: 100), // ADDED
          const SizedBox(height: 16),
          _buildTextFormField(
            _phoneNumberController,
            'Telefon Numarası',
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 100, // ADDED
            validator: (value) {
              if (_isCorporate && (value == null || value.isEmpty)) {
                return 'Kurumsal hesaplar için telefon numarası zorunludur';
              }
              if (value != null && value.isNotEmpty && !RegExp(r'^[0-9+\- ]+$').hasMatch(value)) {
                return 'Geçersiz telefon numarası formatı';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedCity,
            decoration: _buildInputDecoration('Şehir', Icons.location_city_outlined),
            dropdownColor: AppColors.surfaceVariant,
            style: AppTextStyles.input,
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Şehir Seçiniz', style: AppTextStyles.hint),
              ),
              ...CyprusCities.cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city, style: AppTextStyles.input),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
                _selectedDistrict = null;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedDistrict,
            decoration: _buildInputDecoration('İlçe', Icons.location_on_outlined),
            dropdownColor: AppColors.surfaceVariant,
            style: AppTextStyles.input,
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  _selectedCity == null ? 'Önce şehir seçiniz' : 'İlçe Seçiniz',
                  style: AppTextStyles.hint,
                ),
              ),
              ...districts.map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district, style: AppTextStyles.input),
                );
              }),
            ],
            onChanged: _selectedCity == null
                ? null
                : (value) {
                    setState(() {
                      _selectedDistrict = value;
                    });
                  },
          ),
        ],
      ),
    );
  }

  // Step 3: Corporate (only for corporate accounts)
  Widget _buildCorporateStep() {
    return Form(
      key: _formKeys[2],
      child: _buildCard(
        title: 'Kurumsal Bilgiler',
        children: [
          _buildTextFormField(
            _companyNameController,
            'Şirket Adı',
            Icons.business_outlined,
            maxLength: 100, // ADDED
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Şirket adı zorunludur';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            _taxNumberController,
            'Vergi Numarası',
            Icons.numbers,
            keyboardType: TextInputType.number,
            maxLength: 100, // ADDED
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vergi numarası zorunludur';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            _landlinePhoneController,
            'Sabit Telefon',
            Icons.phone_callback_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 100, // ADDED
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            _addressDetailController,
            'Adres Detayı',
            Icons.home_outlined,
            maxLines: 2,
            maxLength: 255, // ADDED
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            _mapsUrlController,
            'Haritalar URL\'si',
            Icons.map_outlined,
            keyboardType: TextInputType.url,
            maxLength: 255, // ADDED
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            _websiteController,
            'Web Sitesi',
            Icons.web_outlined,
            keyboardType: TextInputType.url,
            maxLength: 255, // ADDED
          ),
        ],
      ),
    );
  }

  // Step 4 (or 3 for individual): Profile
  Widget _buildProfileStep() {
    return Form(
      key: _formKeys[3],
      child: _buildCard(
        title: 'Profil Bilgileri',
        children: [
          _buildTextFormField(
            _profileImageUrlController,
            'Profil Fotoğrafı URL\'si',
            Icons.image_outlined,
            keyboardType: TextInputType.url,
            maxLength: 255, // ADDED
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            _bioController,
            'Hakkında',
            Icons.info_outline,
            maxLines: 3,
            maxLength: 1000, // ADDED
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(15),
            ),
            child: SwitchListTile(
              title: Text(
                'Telefon Numarası Görünür Mü?',
                style: AppTextStyles.body,
              ),
              subtitle: Text(
                _isPhoneVisible ? 'Herkes görebilir' : 'Sadece sen görebilirsin',
                style: AppTextStyles.caption,
              ),
              value: _isPhoneVisible,
              onChanged: (bool value) {
                setState(() {
                  _isPhoneVisible = value;
                });
              },
              activeTrackColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Geri', style: AppTextStyles.button),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: _currentStep > 0 ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onNextOrSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black87,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: AppTextStyles.button,
                    ),
                    child: isLoading && _currentStep == _totalSteps - 1
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : Text(
                            _currentStep < _totalSteps - 1 ? 'Devam Et' : 'Kayıt Ol',
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onNextOrSubmit() {
    final logicalIdx = _logicalStep(_currentStep);
    final formKey = _formKeys[logicalIdx];

    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _submitRegistration();
    }
  }

  void _submitRegistration() {
    BlocProvider.of<AuthBloc>(context).add(
      RegisterRequested(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.isEmpty ? null : _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.isEmpty ? null : _phoneNumberController.text.trim(),
        city: _selectedCity,
        accountType: _selectedAccountType.toBackendString(),
        profileImageUrl: _profileImageUrlController.text.isEmpty ? null : _profileImageUrlController.text.trim(),
        bio: _bioController.text.isEmpty ? null : _bioController.text.trim(),
        district: _selectedDistrict,
        isPhoneVisible: _isPhoneVisible,
        companyName: _companyNameController.text.isEmpty ? null : _companyNameController.text.trim(),
        taxNumber: _taxNumberController.text.isEmpty ? null : _taxNumberController.text.trim(),
        landlinePhone: _landlinePhoneController.text.isEmpty ? null : _landlinePhoneController.text.trim(),
        addressDetail: _addressDetailController.text.isEmpty ? null : _addressDetailController.text.trim(),
        mapsUrl: _mapsUrlController.text.isEmpty ? null : _mapsUrlController.text.trim(),
        website: _websiteController.text.isEmpty ? null : _websiteController.text.trim(),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Kayıt Başarılı!',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(this.context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Giriş Yap',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Card(
          color: AppColors.surface,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: AppTextStyles.hint,
      prefixIcon: Icon(icon, color: AppColors.textHint),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      errorStyle: AppTextStyles.error,
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String labelText,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int? maxLength, // ADDED PARAMETER
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: AppTextStyles.input,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength, // USED PARAMETER
      decoration: _buildInputDecoration(labelText, icon, suffixIcon: suffixIcon),
      validator: validator,
      onChanged: labelText == 'Şifre' ? (_) => setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _companyNameController.dispose();
    _taxNumberController.dispose();
    _landlinePhoneController.dispose();
    _addressDetailController.dispose();
    _mapsUrlController.dispose();
    _websiteController.dispose();
    _profileImageUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
