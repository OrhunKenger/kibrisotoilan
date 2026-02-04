import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/cyprus_cities.dart';
import '../../core/constants/enum_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_decorations.dart';
import '../../domain/entities/car_enums.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';
import '../widgets/car_list_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import 'car_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minMileageController = TextEditingController();
  final TextEditingController _maxMileageController = TextEditingController();
  final TextEditingController _engineSizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;
  Currency? _selectedCurrency;
  SteeringType? _selectedSteering;
  BodyType? _selectedBodyType;
  TransmissionType? _selectedTransmission;
  String? _selectedCity;

  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _brandController.addListener(_onSearchChanged);
    _modelController.addListener(_onSearchChanged);
    _loadCars();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCars();
    }
  }

  void _loadMoreCars() {
    final state = context.read<CarBloc>().state;
    if (state is CarsLoaded && !state.hasReachedMax) {
      _loadCars(
        brand: _brandController.text.isEmpty ? null : _brandController.text,
        model: _modelController.text.isEmpty ? null : _modelController.text,
        minPrice: double.tryParse(_minPriceController.text),
        maxPrice: double.tryParse(_maxPriceController.text),
        currency: _selectedCurrency,
        steering: _selectedSteering,
        city: _selectedCity,
        minMileage: int.tryParse(_minMileageController.text),
        maxMileage: int.tryParse(_maxMileageController.text),
        engineSize: int.tryParse(_engineSizeController.text),
        bodyType: _selectedBodyType,
        transmission: _selectedTransmission,
        color: _colorController.text.isEmpty ? null : _colorController.text,
        page: state.currentPage + 1,
      );
    }
  }

  void _loadCars({
    String? brand,
    String? model,
    double? minPrice,
    double? maxPrice,
    Currency? currency,
    SteeringType? steering,
    String? city,
    int? minMileage,
    int? maxMileage,
    int? engineSize,
    BodyType? bodyType,
    TransmissionType? transmission,
    String? color,
    int page = 1,
    int limit = 10,
    String sortBy = "created_at",
    String sortOrder = "desc",
  }) {
    context.read<CarBloc>().add(
      GetCarsEvent(
        brand: brand, model: model,
        minPrice: minPrice, maxPrice: maxPrice,
        currency: currency, steering: steering,
        city: city,
        minMileage: minMileage, maxMileage: maxMileage,
        engineSize: engineSize, bodyType: bodyType,
        transmission: transmission, color: color,
        page: page, limit: limit,
        sortBy: sortBy, sortOrder: sortOrder,
      ),
    );
  }

  void _applyFilters() {
    _loadCars(
      brand: _brandController.text.isEmpty ? null : _brandController.text,
      model: _modelController.text.isEmpty ? null : _modelController.text,
      minPrice: double.tryParse(_minPriceController.text),
      maxPrice: double.tryParse(_maxPriceController.text),
      currency: _selectedCurrency,
      steering: _selectedSteering,
      city: _selectedCity,
      minMileage: int.tryParse(_minMileageController.text),
      maxMileage: int.tryParse(_maxMileageController.text),
      engineSize: int.tryParse(_engineSizeController.text),
      bodyType: _selectedBodyType,
      transmission: _selectedTransmission,
      color: _colorController.text.isEmpty ? null : _colorController.text,
    );
  }

  void _resetFilters() {
    _brandController.clear();
    _modelController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _minMileageController.clear();
    _maxMileageController.clear();
    _engineSizeController.clear();
    _colorController.clear();
    setState(() {
      _selectedCurrency = null;
      _selectedSteering = null;
      _selectedBodyType = null;
      _selectedTransmission = null;
      _selectedCity = null;
    });
    _loadCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlanlar')),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadCars(),
              color: AppColors.primary,
              child: BlocBuilder<CarBloc, CarState>(
                buildWhen: (_, current) =>
                    current is CarLoading ||
                    current is CarsLoaded ||
                    current is CarError ||
                    current is CarInitial,
                builder: (context, state) {
                  if (state is CarLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CarsLoaded) {
                    if (state.cars.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: const EmptyStateWidget(
                              icon: Icons.directions_car_filled,
                              title: 'Henüz ilan yok',
                              subtitle: 'İlk ilanı sen ekle!',
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: state.cars.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.cars.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final car = state.cars[index];
                        return CarListCard(
                          car: car,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<CarBloc>(),
                                  child: CarDetailPage(carId: car.id!),
                                ),
                              ),
                            );
                          },
                          onFavorite: () {
                            context.read<CarBloc>().add(
                              AddFavoriteEvent(carId: car.id!),
                            );
                          },
                        );
                      },
                    );
                  } else if (state is CarError) {
                    return ErrorStateWidget(
                      message: state.message,
                      onRetry: () => _loadCars(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return ExpansionTile(
      initiallyExpanded: _isFilterExpanded,
      onExpansionChanged: (expanded) => setState(() => _isFilterExpanded = expanded),
      title: Text('Detaylı Filtreleme', style: AppTextStyles.subtitle),
      leading: Icon(
        _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list,
        color: AppColors.textPrimary,
      ),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFilterField(_brandController, 'Marka'),
                const SizedBox(height: 10),
                _buildFilterField(_modelController, 'Model'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildFilterField(_minPriceController, 'Min Fiyat', keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildFilterField(_maxPriceController, 'Maks Fiyat', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFilterDropdown<Currency>(
                  'Para Birimi', _selectedCurrency, Currency.values,
                  (v) => setState(() => _selectedCurrency = v),
                  (e) => EnumLabels.currency[e] ?? e.name.toUpperCase(),
                ),
                const SizedBox(height: 10),
                _buildFilterDropdown<String>(
                  'Şehir', _selectedCity, CyprusCities.cities,
                  (v) => setState(() => _selectedCity = v),
                  (e) => e,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildFilterField(_minMileageController, 'Min KM', keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildFilterField(_maxMileageController, 'Maks KM', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFilterField(_engineSizeController, 'Motor Hacmi (cc)', keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildFilterDropdown<BodyType>(
                  'Kasa Tipi', _selectedBodyType, BodyType.values,
                  (v) => setState(() => _selectedBodyType = v),
                  (e) => EnumLabels.bodyType[e] ?? e.name,
                ),
                const SizedBox(height: 10),
                _buildFilterDropdown<TransmissionType>(
                  'Vites Tipi', _selectedTransmission, TransmissionType.values,
                  (v) => setState(() => _selectedTransmission = v),
                  (e) => EnumLabels.transmission[e] ?? e.name,
                ),
                const SizedBox(height: 10),
                _buildFilterDropdown<SteeringType>(
                  'Direksiyon', _selectedSteering, SteeringType.values,
                  (v) => setState(() => _selectedSteering = v),
                  (e) => EnumLabels.steering[e] ?? e.name,
                ),
                const SizedBox(height: 10),
                _buildFilterField(_colorController, 'Renk'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Filtrele'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        child: const Text('Sıfırla'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: AppTextStyles.input,
      keyboardType: keyboardType,
      decoration: AppDecorations.dropdown(label: label),
    );
  }

  Widget _buildFilterDropdown<T>(
    String label, T? value, List<T> items,
    ValueChanged<T?> onChanged, String Function(T) itemLabel,
  ) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: AppDecorations.dropdown(label: label),
      dropdownColor: AppColors.surface,
      style: AppTextStyles.input,
      items: [
        DropdownMenuItem<T>(value: null, child: Text('Seçiniz', style: AppTextStyles.hint)),
        ...items.map((item) => DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)))),
      ],
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _brandController.removeListener(_onSearchChanged);
    _modelController.removeListener(_onSearchChanged);
    _brandController.dispose();
    _modelController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minMileageController.dispose();
    _maxMileageController.dispose();
    _engineSizeController.dispose();
    _colorController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
