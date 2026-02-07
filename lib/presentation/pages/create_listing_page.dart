import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/cyprus_cities.dart';
import '../../core/constants/enum_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/entities/car_enums.dart';
import '../../injection_container.dart' as di;
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';
import '../widgets/brand_model_picker.dart';

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();

  // Temel Bilgiler
  final _titleController = TextEditingController();
  String? _selectedBrand;
  String? _selectedSeries;
  String? _selectedModel;
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();

  // Teknik
  BodyType _selectedBodyType = BodyType.sedan;
  TransmissionType _selectedTransmission = TransmissionType.automatic;
  SteeringType _selectedSteering = SteeringType.left;
  String? _selectedFuelType;
  final _engineSizeController = TextEditingController();
  final _mileageController = TextEditingController();
  MileageUnit _selectedMileageUnit = MileageUnit.km;

  // Fiyat
  final _priceController = TextEditingController();
  Currency _selectedCurrency = Currency.gbp;
  bool _isExchangeable = false;

  // Konum
  String? _selectedCity;
  String? _selectedDistrict;

  // Fotograflar
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;

  // Aciklama
  final _descriptionController = TextEditingController();

  // Cyprus-specific fields
  String _steeringSide = "Sağ";
  String? _registrationStatus;
  final _licenseSeriesController = TextEditingController();

  List<String> get _fuelTypes {
    final svcLabels = EnumLabels.fuelTypeLabels;
    return svcLabels.isNotEmpty ? svcLabels : ['Benzin', 'Dizel', 'LPG', 'Elektrik', 'Hibrit'];
  }

  Map<Currency, String> get _currencyLabels => EnumLabels.currency;
  Map<BodyType, String> get _bodyTypeLabels => EnumLabels.bodyType;
  Map<TransmissionType, String> get _transmissionLabels => EnumLabels.transmission;
  Map<SteeringType, String> get _steeringLabels => EnumLabels.steering;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'İlan Ekle',
          style: AppTextStyles.heading3,
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<CarBloc, CarState>(
        listener: (context, state) {
          if (state is CarCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('İlan başarıyla oluşturuldu!', style: AppTextStyles.body),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            // Refresh car list and pop
            context.read<CarBloc>().add(const GetCarsEvent(
              page: 1,
              limit: 10,
              sortBy: 'created_at',
              sortOrder: 'desc',
            ));
            Navigator.of(context).pop();
          } else if (state is CarCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: ${state.message}', style: AppTextStyles.body),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CarCreating || _isUploading;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Fotoğraflar'),
                      const SizedBox(height: 12),
                      _buildImagePicker(),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Temel Bilgiler'),
                      const SizedBox(height: 12),
                      _buildTextField(_titleController, 'İlan Başlığı', Icons.title,
                          validator: _requiredValidator, maxLength: 120),
                      const SizedBox(height: 12),
                      _buildBrandModelSelector(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(_yearController, 'Yıl', Icons.calendar_today,
                                keyboardType: TextInputType.number, validator: (value) {
                              if (value == null || value.isEmpty) return 'Zorunlu';
                              final year = int.tryParse(value);
                              if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                                return 'Geçerli bir yıl girin';
                              }
                              return null;
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(_colorController, 'Renk', Icons.palette,
                                validator: _requiredValidator, maxLength: 30),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Teknik Bilgiler'),
                      const SizedBox(height: 12),
                      _buildEnumDropdown<BodyType>(
                        'Kasa Tipi',
                        _selectedBodyType,
                        BodyType.values,
                        (v) => setState(() => _selectedBodyType = v!),
                        (e) => _bodyTypeLabels[e] ?? e.name,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEnumDropdown<TransmissionType>(
                              'Vites',
                              _selectedTransmission,
                              TransmissionType.values,
                              (v) => setState(() => _selectedTransmission = v!),
                              (e) => _transmissionLabels[e] ?? e.name,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                                _engineSizeController, 'Motor Hacmi (cc)', Icons.speed,
                                keyboardType: TextInputType.number, validator: (value) {
                              if (value == null || value.isEmpty) return 'Zorunlu';
                              if (int.tryParse(value) == null) return 'Geçerli bir sayı girin';
                              return null;
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                                _mileageController, 'Kilometre', Icons.speed,
                                keyboardType: TextInputType.number, validator: (value) {
                              if (value == null || value.isEmpty) return 'Zorunlu';
                              if (int.tryParse(value) == null) return 'Geçerli bir sayı girin';
                              return null;
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildEnumDropdown<MileageUnit>(
                              'Birim',
                              _selectedMileageUnit,
                              MileageUnit.values,
                              (v) => setState(() => _selectedMileageUnit = v!),
                              (e) => e == MileageUnit.km ? 'KM' : 'Mil',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFuelTypeDropdown(),
                      const SizedBox(height: 12),
                      _buildSectionTitle('Kıbrıs\'a Özel Alanlar'),
                      const SizedBox(height: 12),
                      _buildSteeringSideToggle(),
                      const SizedBox(height: 12),
                      _buildRegistrationStatusDropdown(),
                      const SizedBox(height: 12),
                      _buildLicenseSeriesField(),
                      const SizedBox(height: 12),


                      const SizedBox(height: 24),
                      _buildSectionTitle('Fiyat Bilgileri'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(_priceController, 'Fiyat', Icons.attach_money,
                                keyboardType: TextInputType.number, validator: (value) {
                              if (value == null || value.isEmpty) return 'Zorunlu';
                              if (double.tryParse(value) == null) return 'Geçerli bir fiyat girin';
                              return null;
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildEnumDropdown<Currency>(
                              'Para Birimi',
                              _selectedCurrency,
                              Currency.values,
                              (v) => setState(() => _selectedCurrency = v!),
                              (e) => _currencyLabels[e]?.split(' - ').first ?? e.name,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchTile('Takas Olur', _isExchangeable,
                          (v) => setState(() => _isExchangeable = v)),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Konum'),
                      const SizedBox(height: 12),
                      _buildCityDropdown(),
                      const SizedBox(height: 12),
                      _buildDistrictDropdown(),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Açıklama'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _descriptionController,
                        'İlan açıklaması...',
                        Icons.description,
                        maxLines: 4,
                        maxLength: 2000,
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black87,
                            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'İlanı Yayınla',
                                  style: AppTextStyles.button,
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBrand == null || _selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lutfen marka ve model secin', style: AppTextStyles.body),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen bir şehir seçin', style: AppTextStyles.body),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_registrationStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen kayıt durumu seçin', style: AppTextStyles.body),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Upload images first
    List<String> imageUrls = [];
    if (_selectedImages.isNotEmpty) {
      setState(() => _isUploading = true);
      try {
        final dio = di.sl<Dio>();
        final formData = FormData();
        for (final image in _selectedImages) {
          final bytes = await image.readAsBytes();
          formData.files.add(MapEntry(
            'files',
            MultipartFile.fromBytes(bytes, filename: image.name),
          ));
        }
        final response = await dio.post('/upload/images', data: formData);
        imageUrls = (response.data as List).map((e) => e as String).toList();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resim yüklenemedi: $e', style: AppTextStyles.body),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() => _isUploading = false);
        }
        return;
      }
      if (mounted) setState(() => _isUploading = false);
    }

    // Argo Kelime Filtresi
    if (_containsProfanity(_titleController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İlan başlığında uygunsuz kelimeler tespit edildi. Lütfen düzeltin.', style: AppTextStyles.body),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final car = CarEntity(
      title: _titleController.text.trim(),
      brand: _selectedBrand!,
      model: _selectedModel!,
      year: int.parse(_yearController.text.trim()),
      color: _colorController.text.trim(),
      bodyType: _selectedBodyType,
      transmission: _selectedTransmission,
      steering: _selectedSteering,
      fuelType: _selectedFuelType,
      engineSize: int.parse(_engineSizeController.text.trim()),
      mileage: int.parse(_mileageController.text.trim()),
      mileageUnit: _selectedMileageUnit,
      price: double.parse(_priceController.text.trim()),
      currency: _selectedCurrency,
      isExchangeable: _isExchangeable,
      city: _selectedCity!,
      district: _selectedDistrict,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imageUrls: imageUrls,
      steeringSide: _steeringSide,
      registrationStatus: _registrationStatus!,
      licenseSeries: _licenseSeriesController.text.trim().isEmpty
          ? null
          : _licenseSeriesController.text.trim(),
    );

    if (mounted) context.read<CarBloc>().add(CreateCarEvent(car: car));
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunludur';
    return null;
  }

  bool _containsProfanity(String text) {
    // Kapsamlı yasaklı kelime listesi
    const bannedWords = [
      'küfür1', 'küfür2', 'argo1', 'sik', 'amk', 'piç', 'göt', 'yarrak', 'meme', 'taşak', 'it', 'köpek', 'şerefsiz', 'adi', 'ahlaksız',
      // Buraya daha fazla kelime eklenebilir veya bir servisten çekilebilir
    ];

    final cleanText = text.toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g');

    for (final word in bannedWords) {
      if (cleanText.contains(word)) return true;
    }
    return false;
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.sectionTitle);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.input,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.hint,
        prefixIcon: Icon(icon, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        errorStyle: AppTextStyles.error,
      ),
    );
  }

  Widget _buildEnumDropdown<T>(
    String label,
    T selectedValue,
    List<T> values,
    ValueChanged<T?> onChanged,
    String Function(T) itemToString,
  ) {
    return DropdownButtonFormField<T>(
      initialValue: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dropdownColor: AppColors.surface,
      style: AppTextStyles.input,
      items: values.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(itemToString(value)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildBrandModelSelector() {
    final hasSelection = _selectedBrand != null && _selectedModel != null;
    final displayText = hasSelection
        ? '$_selectedBrand $_selectedSeries $_selectedModel'
        : 'Marka / Model Sec';

    return GestureDetector(
      onTap: () async {
        final result = await showBrandModelPicker(context);
        if (result != null) {
          setState(() {
            _selectedBrand = result.brand;
            _selectedSeries = result.series;
            _selectedModel = result.model;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: hasSelection
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.directions_car,
              color: hasSelection ? AppColors.primary : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayText,
                style: hasSelection ? AppTextStyles.body : AppTextStyles.hint,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedFuelType,
      decoration: InputDecoration(
        labelText: 'Yakıt Tipi',
        labelStyle: AppTextStyles.hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dropdownColor: AppColors.surface,
      style: AppTextStyles.input,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Seçiniz', style: AppTextStyles.hint),
        ),
        ..._fuelTypes.map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }),
      ],
      onChanged: (v) => setState(() => _selectedFuelType = v),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCity,
      decoration: InputDecoration(
        labelText: 'Şehir',
        labelStyle: AppTextStyles.hint,
        prefixIcon: const Icon(Icons.location_city, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dropdownColor: AppColors.surface,
      style: AppTextStyles.input,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Şehir Seçiniz', style: AppTextStyles.hint),
        ),
        ...CyprusCities.cities.map((city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }),
      ],
      onChanged: (v) {
        setState(() {
          _selectedCity = v;
          _selectedDistrict = null;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Şehir seçimi zorunludur';
        return null;
      },
    );
  }

  Widget _buildDistrictDropdown() {
    final districts = _selectedCity != null
        ? CyprusCities.districts[_selectedCity!] ?? []
        : <String>[];
    return DropdownButtonFormField<String>(
      initialValue: _selectedDistrict,
      decoration: InputDecoration(
        labelText: 'İlçe',
        labelStyle: AppTextStyles.hint,
        prefixIcon: const Icon(Icons.location_on, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dropdownColor: AppColors.surface,
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
            child: Text(district),
          );
        }),
      ],
      onChanged: _selectedCity == null ? null : (v) => setState(() => _selectedDistrict = v),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.input),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        if (_selectedImages.length > 10) {
          _selectedImages.removeRange(10, _selectedImages.length);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('En fazla 10 fotoğraf ekleyebilirsiniz', style: AppTextStyles.body),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FutureBuilder<Uint8List>(
                          future: _selectedImages[index].readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              );
                            }
                            return Container(
                              width: 120,
                              height: 120,
                              color: AppColors.surfaceLight,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImages.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      if (index == 0)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Kapak',
                              style: AppTextStyles.button.copyWith(fontSize: 10, color: Colors.black87),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: _selectedImages.length >= 10 ? null : _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: _selectedImages.length >= 10 ? AppColors.textHint : AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImages.isEmpty
                      ? 'Fotoğraf Ekle (max 10)'
                      : '${_selectedImages.length}/10 fotoğraf seçildi',
                  style: AppTextStyles.body.copyWith(
                    color: _selectedImages.length >= 10 ? AppColors.textHint : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSteeringSideToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Direksiyon Yönü', style: AppTextStyles.caption),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Sağ', label: Text('Sağ'), icon: Icon(Icons.directions_car)),
            ButtonSegment(value: 'Sol', label: Text('Sol'), icon: Icon(Icons.directions_car_outlined)),
          ],
          selected: {_steeringSide},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _steeringSide = newSelection.first;
            });
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            selectedForegroundColor: Colors.black,
            selectedBackgroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationStatusDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _registrationStatus,
      decoration: InputDecoration(
        labelText: 'Kayıt Durumu',
        labelStyle: AppTextStyles.hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: AppColors.surface,
      style: AppTextStyles.input,
      items: ["Kıbrıs Kayıtlı", "Gümrüksüz / Yeni İthal", "Ziyaretçi Plaka"]
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _registrationStatus = value;
        });
      },
      validator: (value) => value == null ? 'Bu alan zorunludur' : null,
    );
  }

  Widget _buildLicenseSeriesField() {
    return Visibility(
      visible: _registrationStatus == 'Kıbrıs Kayıtlı',
      child: _buildTextField(
        _licenseSeriesController,
        'Plaka Serisi (örn: ZK, UB)',
        Icons.label_important_outline,
        validator: (value) {
          if (_registrationStatus == 'Kıbrıs Kayıtlı' && (value == null || value.isEmpty)) {
            return 'Plaka serisi zorunludur';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _engineSizeController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _licenseSeriesController.dispose();
    super.dispose();
  }
}
