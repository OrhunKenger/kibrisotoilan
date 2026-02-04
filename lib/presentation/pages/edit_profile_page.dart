import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/cyprus_cities.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/app_dropdown.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
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
  late bool _isPhoneVisible;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _fullNameController = TextEditingController(text: u.fullName ?? '');
    _phoneController = TextEditingController(text: u.phoneNumber ?? '');
    _bioController = TextEditingController(text: u.bio ?? '');
    _companyNameController = TextEditingController(text: u.companyName ?? '');
    _taxNumberController = TextEditingController(text: u.taxNumber ?? '');
    _landlinePhoneController = TextEditingController(text: u.landlinePhone ?? '');
    _addressDetailController = TextEditingController(text: u.addressDetail ?? '');
    _websiteController = TextEditingController(text: u.website ?? '');
    _mapsUrlController = TextEditingController(text: u.mapsUrl ?? '');
    _selectedCity = (u.city != null && CyprusCities.cities.contains(u.city)) ? u.city : null;
    _selectedDistrict = (u.district != null && _selectedCity != null &&
        (CyprusCities.districts[_selectedCity!] ?? []).contains(u.district)) ? u.district : null;
    _isPhoneVisible = u.isPhoneVisible ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profili Düzenle')),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil güncellendi'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is UserUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is UserUpdating;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _fullNameController,
                    label: 'Ad Soyad',
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Telefon',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
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
                        : (v) => setState(() => _selectedDistrict = v),
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
                      onChanged: (v) => setState(() => _isPhoneVisible = v),
                      activeTrackColor: AppColors.primary,
                    ),
                  ),

                  // Corporate fields
                  if (widget.user.companyName != null) ...[
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
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _taxNumberController,
                      label: 'Vergi Numarası',
                      prefixIcon: Icons.numbers,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _landlinePhoneController,
                      label: 'Sabit Telefon',
                      prefixIcon: Icons.phone_callback,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _addressDetailController,
                      label: 'Adres',
                      prefixIcon: Icons.home,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _websiteController,
                      label: 'Web Sitesi',
                      prefixIcon: Icons.web,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _mapsUrlController,
                      label: 'Haritalar URL',
                      prefixIcon: Icons.map,
                      keyboardType: TextInputType.url,
                    ),
                  ],

                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Kaydet',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'full_name': _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
      'phone_number': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      'city': _selectedCity,
      'district': _selectedDistrict,
      'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      'is_phone_visible': _isPhoneVisible,
    };

    if (widget.user.companyName != null) {
      data['company_name'] = _companyNameController.text.trim().isEmpty ? null : _companyNameController.text.trim();
      data['tax_number'] = _taxNumberController.text.trim().isEmpty ? null : _taxNumberController.text.trim();
      data['landline_phone'] = _landlinePhoneController.text.trim().isEmpty ? null : _landlinePhoneController.text.trim();
      data['address_detail'] = _addressDetailController.text.trim().isEmpty ? null : _addressDetailController.text.trim();
      data['website'] = _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim();
      data['maps_url'] = _mapsUrlController.text.trim().isEmpty ? null : _mapsUrlController.text.trim();
    }

    // Remove null values so we only send fields that are set
    data.removeWhere((key, value) => value == null);

    context.read<UserBloc>().add(UpdateUserProfileEvent(data: data));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
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
