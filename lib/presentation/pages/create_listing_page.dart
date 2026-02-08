import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../../data/models/lookup_model.dart';
import '../../core/theme/app_colors.dart';
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
  late ImageLabeler _imageLabeler;

  // Selection States
  BrandEntity? _selectedBrandEntity;
  SeriesModels? _selectedSeriesEntity;
  String? _selectedModelName;
  
  List<BrandEntity> _allBrands = [];
  List<SeriesModels> _seriesModels = [];
  List<String> _models = [];

  // Controllers
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _engineSizeController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _licenseSeriesController = TextEditingController();

  // Selections
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
  final List<String> _uploadedImageUrls = []; 
  bool _isUploading = false;
  bool _isGeneratingTitle = false;
  bool _isGeneratingDesc = false;
  bool _isTitleGenerated = false;
  bool _isDescGenerated = false;
  Map<String, dynamic>? _aiSuggestion; 

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initializeImageLabeler();
  }

  void _initializeImageLabeler() {
    if (kIsWeb) return;
    try {
      _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.6));
    } catch (e) { if (kDebugMode) print(e); }
  }

  void _loadInitialData() {
    context.read<CarBloc>().add(const GetAllBrandsEvent());
    _lookupService.loadLookups().then((_) { if (mounted) setState(() {}); });
  }

  Future<void> _startBackgroundAnalysis(List<XFile> images) async {
    try {
      final dio = di.sl<Dio>();
      final formData = FormData();
      for (final image in images) {
        final bytes = await image.readAsBytes();
        formData.files.add(MapEntry('files', MultipartFile.fromBytes(bytes, filename: image.name)));
      }
      final response = await dio.post('/upload/images?analyze=true', data: formData);
      if (response.data is Map && mounted) {
        setState(() {
          _aiSuggestion = response.data['ai_suggestion'];
          if (response.data['urls'] != null) {
            _uploadedImageUrls.addAll(List<String>.from(response.data['urls']));
          }
          _isUploading = false;
        });
        if (_aiSuggestion != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yapay Zeka Önerisi Hazır!'), backgroundColor: AppColors.primary));
        }
      }
    } catch (e) { if (mounted) setState(() => _isUploading = false); }
  }

  bool _checkInfoForAI() {
    if (_selectedBrandEntity == null || _yearController.text.isEmpty || _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI için önce Marka, Yıl ve Renk bilgilerini girmelisiniz.'), backgroundColor: Colors.orange),
      );
      return false;
    }
    return true;
  }

  Future<void> _generateAIContent(bool isTitle) async {
    if (!_checkInfoForAI()) return;
    if (isTitle && _isTitleGenerated) return;
    if (!isTitle && _isDescGenerated) return;

    setState(() { if (isTitle) _isGeneratingTitle = true; else _isGeneratingDesc = true; });
    
    try {
      final dio = di.sl<Dio>();
      final response = await dio.post('/ai/generate-content', data: {
        "brand": _selectedBrandEntity!.name,
        "model": _selectedModelName ?? _selectedSeriesEntity?.series ?? "",
        "year": int.tryParse(_yearController.text) ?? 2024,
        "color": _selectedColor ?? "Beyaz"
      });
      if (response.data != null) {
        setState(() {
          if (isTitle) {
            _titleController.text = response.data['title'] ?? _titleController.text;
            _isTitleGenerated = true;
          } else {
            _descriptionController.text = response.data['description'] ?? _descriptionController.text;
            _isDescGenerated = true;
          }
        });
      }
    } catch (e) { print(e); }
    setState(() { if (isTitle) _isGeneratingTitle = false; else _isGeneratingDesc = false; });
  }

  void _showAIReviewDialog() {
    if (_aiSuggestion == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(children: [Icon(Icons.auto_awesome, color: AppColors.primary), SizedBox(width: 10), Text('AI Önerilerini İncele', style: TextStyle(color: Colors.white, fontSize: 18))]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReviewItem('Marka', _aiSuggestion!['suggested_brand']),
            _buildReviewItem('Model', _aiSuggestion!['suggested_model']),
            _buildReviewItem('Yıl', _aiSuggestion!['suggested_year']?.toString()),
            _buildReviewItem('Renk', _aiSuggestion!['suggested_color']),
            _buildReviewItem('Direksiyon', _aiSuggestion!['suggested_steering']),
            const SizedBox(height: 12),
            const Text('* Onayladığınızda form otomatik dolacaktır.', style: TextStyle(color: AppColors.textHint, fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _applyAISuggestion(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Onayla ve Doldur', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$label:', style: const TextStyle(color: AppColors.textHint, fontSize: 13)), Text(value ?? 'Bilinmiyor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
    );
  }

  void _applyAISuggestion() {
    final lookups = _lookupService.data;
    setState(() {
      if (_aiSuggestion!['suggested_brand'] != null) {
        try {
          final brand = _allBrands.firstWhere((b) => b.name.toLowerCase() == _aiSuggestion!['suggested_brand'].toString().toLowerCase());
          _onBrandTap(brand);
          if (_aiSuggestion!['suggested_model'] != null) {
            _titleController.text = "${brand.name} ${_aiSuggestion!['suggested_model']}";
          }
        } catch (_) {}
      }
      if (_aiSuggestion!['suggested_year'] != null) _yearController.text = _aiSuggestion!['suggested_year'].toString();
      
      if (_aiSuggestion!['suggested_color'] != null) {
        final color = _aiSuggestion!['suggested_color'].toString();
        if (lookups.colors.any((e) => e.labelTr == color)) _selectedColor = color;
      }

      if (_aiSuggestion!['suggested_steering'] != null) {
        _selectedSteering = _aiSuggestion!['suggested_steering'] == 'Sağ' ? SteeringType.right : SteeringType.left;
      }
      _aiSuggestion = null;
    });
  }

  void _onBrandTap(BrandEntity brand) {
    setState(() { _selectedBrandEntity = brand; _selectedSeriesEntity = null; _selectedModelName = null; _seriesModels = []; });
    context.read<CarBloc>().add(GetSeriesAndModelsEvent(brandId: brand.id));
  }

  void _onSeriesTap(SeriesModels series) {
    setState(() { _selectedSeriesEntity = series; _selectedModelName = null; _models = series.models; });
  }

  @override
  Widget build(BuildContext context) {
    final lookups = _lookupService.data;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Yeni İlan Ver', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.background, elevation: 0),
      body: BlocConsumer<CarBloc, CarState>(
        listener: (context, state) {
          if (state is AllBrandsLoaded) _allBrands = state.brands;
          if (state is SeriesAndModelsLoaded) _seriesModels = state.seriesModels;
          if (state is CarCreated) { Navigator.pop(context); }
        },
        builder: (context, state) {
          final isSubmitting = state is CarCreating;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_aiSuggestion != null) _buildAISuggestionCard(),
                      _buildSectionTitle('Araç Seçimi (Kademeli)'),
                      _buildFocusSelectionBand(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Fotoğraflar'),
                      _buildImagePickerBox(),
                      const SizedBox(height: 24),
                      _buildSectionHeaderWithAI('İlan Başlığı', _isGeneratingTitle, _isTitleGenerated, () => _generateAIContent(true)),
                      _buildTextField(_titleController, 'Etkileyici bir başlık girin', Icons.title),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildTextField(_priceController, 'Fiyat', Icons.payments, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown<Currency>(label: 'Birim', value: _selectedCurrency, items: Currency.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(), onChanged: (v) => setState(() => _selectedCurrency = v!), icon: Icons.currency_exchange)),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildTextField(_yearController, 'Model Yılı', Icons.calendar_today, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown<String>(label: 'Renk', value: _selectedColor, items: lookups.colors.map((e) => DropdownMenuItem(value: e.labelTr, child: Text(e.labelTr))).toList(), onChanged: (v) => setState(() => _selectedColor = v), icon: Icons.palette)),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildTextField(_mileageController, 'Kilometre', Icons.speed, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown<MileageUnit>(label: 'Birim', value: _selectedMileageUnit, items: const [DropdownMenuItem(value: MileageUnit.km, child: Text('KM')), DropdownMenuItem(value: MileageUnit.miles, child: Text('Mil'))], onChanged: (v) => setState(() => _selectedMileageUnit = v!), icon: Icons.straighten)),
                      ]),
                      const SizedBox(height: 16),
                      _buildTextField(_engineSizeController, 'Motor Hacmi (cc)', Icons.shutter_speed, keyboardType: TextInputType.number),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Teknik Detaylar'),
                      _buildDropdown<String>(label: 'Yakıt Tipi', value: _selectedFuelType, items: lookups.fuelTypes.map((e) => DropdownMenuItem(value: e.value, child: Text(e.labelTr))).toList(), onChanged: (v) => setState(() => _selectedFuelType = v), icon: Icons.local_gas_station),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildDropdown<TransmissionType>(label: 'Vites', value: _selectedTransmission, items: TransmissionType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(), onChanged: (v) => setState(() => _selectedTransmission = v!), icon: Icons.settings)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown<SteeringType>(label: 'Direksiyon', value: _selectedSteering, items: const [DropdownMenuItem(value: SteeringType.right, child: Text('Sağ')), DropdownMenuItem(value: SteeringType.left, child: Text('Sol'))], onChanged: (v) => setState(() => _selectedSteering = v!), icon: Icons.directions_car)),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildDropdown<String>(label: 'Şehir', value: _selectedCity, items: lookups.cities.map((e) => DropdownMenuItem(value: e.value, child: Text(e.labelTr))).toList(), onChanged: (v) => setState(() { _selectedCity = v; _selectedDistrict = null; }), icon: Icons.location_on)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown<String>(label: 'Kayıt Durumu', value: _registrationStatus, items: ["Kıbrıs Kayıtlı", "Gümrüksüz", "Ziyaretçi"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _registrationStatus = v), icon: Icons.assignment)),
                      ]),
                      const SizedBox(height: 16),
                      if (_registrationStatus == 'Kıbrıs Kayıtlı') ...[
                        _buildTextField(_licenseSeriesController, 'Plaka Serisi (örn: ZK)', Icons.badge),
                        const SizedBox(height: 16),
                      ],
                      Container(
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                        child: SwitchListTile(
                          title: const Text('Takas Olur mu?', style: TextStyle(color: Colors.white, fontSize: 14)),
                          value: _isExchangeable,
                          onChanged: (v) => setState(() => _isExchangeable = v),
                          activeTrackColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeaderWithAI('İlan Açıklaması', _isGeneratingDesc, _isDescGenerated, () => _generateAIContent(false)),
                      _buildTextField(_descriptionController, 'Araç durumu, ekstralar vb...', Icons.description, maxLines: 4),
                      const SizedBox(height: 40),
                      SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: isSubmitting ? null : _submitForm, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: isSubmitting ? const CircularProgressIndicator() : const Text('İLANIN YAYINLA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              if (isSubmitting) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeaderWithAI(String title, bool loading, bool done, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        if (!done) TextButton.icon(
          onPressed: loading ? null : onTap,
          icon: loading ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
          label: Text(loading ? 'Yazılıyor...' : 'AI ile Yaz', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
        ) else const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
      ],
    );
  }

  Widget _buildAISuggestionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20), const SizedBox(width: 8), const Text('Yapay Zeka Önerisi', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: () => setState(() => _aiSuggestion = null), icon: const Icon(Icons.close, size: 18, color: AppColors.textHint))]),
          const SizedBox(height: 8),
          Text('Tespit edilen: ${_aiSuggestion!['suggested_brand'] ?? ''} ${_aiSuggestion!['suggested_model'] ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: TextButton(onPressed: _showAIReviewDialog, style: TextButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black), child: const Text('Önerileri Gözden Geçir', style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildImagePickerBox() {
    return Column(children: [
      if (_selectedImages.isNotEmpty) SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _selectedImages.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(right: 8), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_selectedImages[index].path, width: 80, height: 80, fit: BoxFit.cover))))),
      const SizedBox(height: 12),
      InkWell(
        onTap: _isUploading ? null : () async {
          final imgs = await ImagePicker().pickMultiImage();
          if (imgs.isNotEmpty) { setState(() { _isUploading = true; _selectedImages.addAll(imgs); }); _startBackgroundAnalysis(imgs); }
        },
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.2))), child: Column(children: [ _isUploading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_a_photo, color: AppColors.primary), const SizedBox(height: 8), Text(_isUploading ? 'Analiz Ediliyor...' : 'Fotoğraf Ekle', style: const TextStyle(color: AppColors.primary))])),
      )
    ]);
  }

  Widget _buildFocusSelectionBand() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey('${_selectedBrandEntity?.id}_${_selectedSeriesEntity?.id}_$_selectedModelName'),
        height: 110,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            if (_selectedBrandEntity == null) ..._allBrands.map((b) => _buildSelectionCircle(b.name, b.logoUrl, () => _onBrandTap(b)))
            else ...[
              _buildSelectionCircle(_selectedBrandEntity!.name, _selectedBrandEntity!.logoUrl, () => setState(() => _selectedBrandEntity = null), isSelected: true),
              const VerticalDivider(color: Colors.white10, indent: 25, endIndent: 25),
              if (_selectedSeriesEntity == null) ..._seriesModels.map((s) => _buildSelectionCircle(s.series, null, () => _onSeriesTap(s)))
              else ...[
                _buildSelectionCircle(_selectedSeriesEntity!.series, null, () => setState(() => _selectedSeriesEntity = null), isSelected: true),
                const VerticalDivider(color: Colors.white10, indent: 25, endIndent: 25),
                ..._models.map((m) => _buildSelectionCircle(m, null, () => setState(() => _selectedModelName = m), isSelected: _selectedModelName == m))
              ]
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCircle(String label, String? img, VoidCallback onTap, {bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70, padding: const EdgeInsets.all(8),
        child: Column(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.white, shape: BoxShape.circle), child: img != null ? CachedNetworkImage(imageUrl: img, fit: BoxFit.contain) : Center(child: Text(label[0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9), overflow: TextOverflow.ellipsis)
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)));

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(controller: ctrl, maxLines: maxLines, keyboardType: keyboardType, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppColors.textHint), prefixIcon: Icon(icon, color: AppColors.primary, size: 20), filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged, required IconData icon}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)), child: DropdownButtonHideUnderline(child: DropdownButton<T>(value: value, items: items, onChanged: onChanged, isExpanded: true, dropdownColor: AppColors.surface, style: const TextStyle(color: Colors.white, fontSize: 14))));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedBrandEntity == null) return;
    
    final car = CarEntity(
      title: _titleController.text,
      brand: _selectedBrandEntity!.name,
      model: "${_selectedSeriesEntity?.series ?? ''} ${_selectedModelName ?? ''}",
      year: int.tryParse(_yearController.text) ?? 2024,
      price: double.tryParse(_priceController.text) ?? 0,
      currency: _selectedCurrency,
      city: _selectedCity ?? 'Lefkoşa',
      district: _selectedDistrict,
      color: _selectedColor ?? 'Beyaz',
      mileage: int.tryParse(_mileageController.text) ?? 0,
      mileageUnit: _selectedMileageUnit,
      engineSize: int.tryParse(_engineSizeController.text) ?? 0,
      fuelType: _selectedFuelType,
      bodyType: _selectedBodyType,
      transmission: _selectedTransmission,
      steering: _selectedSteering,
      steeringSide: _selectedSteering == SteeringType.right ? 'Sağ' : 'Sol',
      registrationStatus: _registrationStatus ?? 'Kıbrıs Kayıtlı',
      licenseSeries: _licenseSeriesController.text,
      isExchangeable: _isExchangeable,
      description: _descriptionController.text,
      imageUrls: _uploadedImageUrls, 
    );
    context.read<CarBloc>().add(CreateCarEvent(car: car));
  }

  @override
  void dispose() {
    if (!kIsWeb) _imageLabeler.close();
    _titleController.dispose(); _yearController.dispose(); _engineSizeController.dispose();
    _mileageController.dispose(); _priceController.dispose(); _descriptionController.dispose();
    _licenseSeriesController.dispose();
    super.dispose();
  }
}
