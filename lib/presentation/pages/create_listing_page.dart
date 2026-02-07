import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';

import '../../data/models/lookup_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/lookup_service.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/entities/car_enums.dart';
import '../../domain/entities/brand_entity.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';
import '../../injection_container.dart' as di;

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _lookupService = GetIt.I<LookupService>();

  // 3-Step Selection State
  BrandEntity? _selectedBrandEntity;
  SeriesModels? _selectedSeriesEntity;
  String? _selectedModelName;
  
  List<BrandEntity> _allBrands = [];
  List<SeriesModels> _seriesModels = [];
  List<String> _models = [];

  // Form Controllers
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _engineSizeController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _licenseSeriesController = TextEditingController();

  // Form Selections
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedColor;
  String? _selectedFuelType;
  BodyType _selectedBodyType = BodyType.sedan;
  TransmissionType _selectedTransmission = TransmissionType.automatic;
  SteeringType _selectedSteering = SteeringType.right;
  Currency _selectedCurrency = Currency.gbp;
  MileageUnit _selectedMileageUnit = MileageUnit.km;
  String? _registrationStatus;
  bool _isExchangeable = false;

  final List<XFile> _selectedImages = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final carBloc = context.read<CarBloc>();
    carBloc.add(const GetAllBrandsEvent());
    
    _lookupService.loadLookups().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _onBrandTap(BrandEntity brand) {
    setState(() {
      _selectedBrandEntity = brand;
      _selectedSeriesEntity = null;
      _selectedModelName = null;
      _seriesModels = [];
    });
    context.read<CarBloc>().add(GetSeriesAndModelsEvent(brandId: brand.id));
  }

  void _onSeriesTap(SeriesModels series) {
    setState(() {
      _selectedSeriesEntity = series;
      _selectedModelName = null;
      _models = series.models;
    });
  }

  void _onModelTap(String modelName) {
    setState(() => _selectedModelName = modelName);
  }

  @override
  Widget build(BuildContext context) {
    final lookups = _lookupService.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni İlan Yayınla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<CarBloc, CarState>(
        listener: (context, state) {
          if (state is AllBrandsLoaded) {
            setState(() => _allBrands = state.brands);
          } else if (state is SeriesAndModelsLoaded) {
            setState(() => _seriesModels = state.seriesModels);
          } else if (state is CarCreated) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlanınız başarıyla yayına alındı!'), backgroundColor: Colors.green));
            context.read<CarBloc>().add(const GetCarsEvent(page: 1, limit: 20, sortBy: 'created_at', sortOrder: 'desc'));
            Navigator.pop(context);
          } else if (state is CarCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CarCreating || _isUploading;
          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Araç Seçimi (Kademeli)'),
                      const SizedBox(height: 12),
                      _buildFocusSelectionBand(),
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle('Araç Görselleri'),
                      const SizedBox(height: 12),
                      _buildImagePickerBox(),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Genel Bilgiler'),
                      const SizedBox(height: 16),
                      _buildTextField(_titleController, 'İlan Başlığı', Icons.title, validator: _requiredValidator),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_priceController, 'Satış Fiyatı', Icons.payments_outlined, keyboardType: TextInputType.number, validator: _requiredValidator)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDropdown<Currency>(
                            label: 'Birim',
                            value: _selectedCurrency,
                            items: Currency.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase().replaceAll('_', '')))).toList(),
                            onChanged: (v) => setState(() => _selectedCurrency = v!),
                            icon: Icons.currency_exchange,
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(child: _buildTextField(_yearController, 'Üretim Yılı', Icons.calendar_today_outlined, keyboardType: TextInputType.number, validator: _requiredValidator)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDropdown<String>(
                            label: 'Renk',
                            value: _selectedColor,
                            items: lookups.colors.map((e) => DropdownMenuItem(value: e.labelTr, child: Text(e.labelTr))).toList(),
                            onChanged: (v) => setState(() => _selectedColor = v),
                            icon: Icons.palette_outlined,
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildSectionTitle('Teknik Detaylar'),
                      const SizedBox(height: 16),
                      _buildDropdown<String>(
                        label: 'Yakıt Tipi',
                        value: _selectedFuelType,
                        items: lookups.fuelTypes.map((e) => DropdownMenuItem(value: e.value, child: Text(e.labelTr))).toList(),
                        onChanged: (v) => setState(() => _selectedFuelType = v),
                        icon: Icons.local_gas_station_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDropdown<TransmissionType>(
                            label: 'Vites Türü',
                            value: _selectedTransmission,
                            items: TransmissionType.values.map((e) => DropdownMenuItem(value: e, child: Text(_getTransmissionLabel(e)))).toList(),
                            onChanged: (v) => setState(() => _selectedTransmission = v!),
                            icon: Icons.settings_input_component_outlined,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDropdown<SteeringType>(
                            label: 'Direksiyon',
                            value: _selectedSteering,
                            items: const [
                              DropdownMenuItem(value: SteeringType.right, child: Text('Sağ Direksiyon')),
                              DropdownMenuItem(value: SteeringType.left, child: Text('Sol Direksiyon')),
                            ],
                            onChanged: (v) => setState(() => _selectedSteering = v!),
                            icon: Icons.directions_car_outlined,
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<BodyType>(
                        label: 'Kasa Tipi',
                        value: _selectedBodyType,
                        items: lookups.bodyTypes.map((e) {
                          BodyType type = BodyType.values.firstWhere((bt) => bt.name == e.value.replaceAll('-', ''), orElse: () => BodyType.sedan);
                          return DropdownMenuItem(value: type, child: Text(e.labelTr));
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedBodyType = v!),
                        icon: Icons.directions_car_filled_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_mileageController, 'Kilometre (Odo)', Icons.speed, keyboardType: TextInputType.number, validator: _requiredValidator)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDropdown<MileageUnit>(
                            label: 'Birim',
                            value: _selectedMileageUnit,
                            items: const [DropdownMenuItem(value: MileageUnit.km, child: Text('KM')), DropdownMenuItem(value: MileageUnit.miles, child: Text('Mil'))],
                            onChanged: (v) => setState(() => _selectedMileageUnit = v!),
                            icon: Icons.straighten,
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_engineSizeController, 'Motor Hacmi (örn: 1600)', Icons.shutter_speed_outlined, keyboardType: TextInputType.number),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Konum & Kayıt'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDropdown<String>(
                            label: 'Şehir',
                            value: _selectedCity,
                            items: lookups.cities.map((e) => DropdownMenuItem(value: e.value, child: Text(e.labelTr))).toList(),
                            onChanged: (v) => setState(() { _selectedCity = v; _selectedDistrict = null; }),
                            icon: Icons.location_on_outlined,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDropdown<String>(
                            label: 'İlçe',
                            value: _selectedDistrict,
                            items: (lookups.cities.firstWhere((c) => c.value == _selectedCity, orElse: () => const CityLookup(id: 0, value: '', labelTr: '')).districts)
                                .map((e) => DropdownMenuItem(value: e.value, child: Text(e.labelTr))).toList(),
                            onChanged: (v) => setState(() => _selectedDistrict = v),
                            icon: Icons.map_outlined,
                            hint: _selectedCity == null ? 'Önce Şehir' : 'İlçe Seç',
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<String>(
                        label: 'Kayıt Durumu',
                        value: _registrationStatus,
                        items: ["Kıbrıs Kayıtlı", "Gümrüksüz / Yeni İthal", "Ziyaretçi Plaka"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _registrationStatus = v),
                        icon: Icons.assignment_outlined,
                      ),
                      const SizedBox(height: 16),
                      if (_registrationStatus == 'Kıbrıs Kayıtlı')
                        _buildTextField(_licenseSeriesController, 'Plaka Serisi (örn: ZK, UB)', Icons.badge_outlined),
                      
                      const SizedBox(height: 12),
                      _buildSwitchTile('Araç Takasa Uygun', _isExchangeable, (v) => setState(() => _isExchangeable = v)),

                      const SizedBox(height: 32),
                      _buildSectionTitle('Açıklama'),
                      const SizedBox(height: 12),
                      _buildTextField(_descriptionController, 'Araç durumu, ekstralar vb...', Icons.description_outlined, maxLines: 4),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: isSubmitting 
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text('İLANIN YAYINLA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
              if (isSubmitting)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFocusSelectionBand() {
    return BlocBuilder<CarBloc, CarState>(
      buildWhen: (prev, curr) => curr is AllBrandsLoaded || curr is SeriesAndModelsLoaded,
      builder: (context, state) {
        if (state is AllBrandsLoaded) {
          _allBrands = state.brands;
        } else if (state is SeriesAndModelsLoaded) {
          _seriesModels = state.seriesModels;
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Container(
            key: ValueKey('${_selectedBrandEntity?.id}_${_selectedSeriesEntity?.series}_${_selectedModelName}'),
            height: 110,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                if (_selectedBrandEntity == null)
                  ..._allBrands.map((b) => _buildSelectionCircle(
                    label: b.name,
                    image: b.logoUrl,
                    onTap: () => _onBrandTap(b),
                  ))
                else if (_selectedSeriesEntity == null) ...[
                  _buildSelectionCircle(image: _selectedBrandEntity!.logoUrl, label: _selectedBrandEntity!.name, isSelected: true, onTap: () => setState(() => _selectedBrandEntity = null)),
                  const VerticalDivider(width: 30, thickness: 1, color: Colors.white10, indent: 25, endIndent: 25),
                  ..._seriesModels.map((s) => _buildSelectionCircle(label: s.series, onTap: () => _onSeriesTap(s))),
                ]
                else ...[
                  _buildSelectionCircle(image: _selectedBrandEntity!.logoUrl, label: _selectedBrandEntity!.name, isSelected: true, onTap: () => setState(() { _selectedBrandEntity = null; _selectedSeriesEntity = null; })),
                  _buildSelectionCircle(label: _selectedSeriesEntity!.series, isSelected: true, onTap: () => setState(() => _selectedSeriesEntity = null)),
                  const VerticalDivider(width: 30, thickness: 1, color: Colors.white10, indent: 25, endIndent: 25),
                  ..._models.map((m) => _buildSelectionCircle(label: m, isSelected: _selectedModelName == m, onTap: () => _onModelTap(m))),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionCircle({required String label, String? image, bool isSelected = false, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              width: 54, height: 50,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (image != null ? Colors.white : AppColors.background),
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : Colors.white10, width: 1.5),
              ),
              child: image != null 
                ? CachedNetworkImage(imageUrl: image, fit: BoxFit.contain, errorWidget: (c,u,e) => const Icon(Icons.directions_car, size: 20, color: Colors.black54))
                : Center(child: Text(label.substring(0, label.length > 3 ? 3 : label.length).toUpperCase(), style: TextStyle(color: isSelected ? Colors.black : AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(width: 60, child: Text(label, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textHint, fontSize: 9))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
        errorStyle: const TextStyle(color: AppColors.error),
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?>? onChanged, required IconData icon, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 18),
              hint: Text(hint ?? 'Seçiniz', style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }

  Widget _buildImagePickerBox() {
    return Column(
      children: [
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 10),
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
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          }
                          return Container(width: 100, height: 100, color: AppColors.surface);
                        },
                      ),
                    ),
                    Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => _selectedImages.removeAt(index)), child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 12, color: Colors.white)))),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final images = await ImagePicker().pickMultiImage(imageQuality: 70);
            if (images.isNotEmpty) setState(() => _selectedImages.addAll(images));
          },
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
            child: Column(children: [const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 36), const SizedBox(height: 8), Text('Fotoğraf Ekle (Maks 10)', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600))]),
          ),
        ),
      ],
    );
  }

  String _getTransmissionLabel(TransmissionType e) {
    switch(e) {
      case TransmissionType.manual: return 'Manuel';
      case TransmissionType.automatic: return 'Otomatik';
      case TransmissionType.semiAutomatic: return 'Yarı Otomatik';
    }
  }

  String? _requiredValidator(String? value) => value == null || value.trim().isEmpty ? 'Bu alan zorunludur' : null;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedBrandEntity == null || _selectedSeriesEntity == null || _selectedModelName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm zorunlu alanları ve araç seçimini tamamlayın.')));
      return;
    }

    setState(() => _isUploading = true);
    
    List<String> imageUrls = [];
    try {
      if (_selectedImages.isNotEmpty) {
        final dio = di.sl<Dio>();
        final formData = FormData();
        for (final image in _selectedImages) {
          final bytes = await image.readAsBytes();
          formData.files.add(MapEntry('files', MultipartFile.fromBytes(bytes, filename: image.name)));
        }
        final response = await dio.post('/upload/images', data: formData);
        imageUrls = (response.data as List).map((e) => e as String).toList();
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resim yükleme hatası: $e')));
      return;
    }

    final car = CarEntity(
      title: _titleController.text.trim(),
      brand: _selectedBrandEntity!.name,
      model: "${_selectedSeriesEntity!.series} ${_selectedModelName!}", // Örn: "A3 30 TFSI Sport"
      year: int.parse(_yearController.text),
      price: double.parse(_priceController.text),
      currency: _selectedCurrency,
      mileage: int.parse(_mileageController.text),
      mileageUnit: _selectedMileageUnit,
      city: _selectedCity!,
      district: _selectedDistrict,
      color: _selectedColor!,
      fuelType: _selectedFuelType,
      bodyType: _selectedBodyType,
      transmission: _selectedTransmission,
      steering: _selectedSteering,
      engineSize: int.tryParse(_engineSizeController.text) ?? 0,
      steeringSide: _getSteeringSideLabel(_selectedSteering),
      imageUrls: imageUrls,
      description: _descriptionController.text,
      registrationStatus: _registrationStatus!,
      licenseSeries: _licenseSeriesController.text,
    );

    context.read<CarBloc>().add(CreateCarEvent(car: car));
    setState(() => _isUploading = false);
  }

  String _getSteeringSideLabel(SteeringType type) {
    return type == SteeringType.right ? 'Sağ' : 'Sol';
  }

  @override
  void dispose() {
    _titleController.dispose(); _yearController.dispose(); _engineSizeController.dispose();
    _mileageController.dispose(); _priceController.dispose(); _descriptionController.dispose();
    _licenseSeriesController.dispose();
    super.dispose();
  }
}
