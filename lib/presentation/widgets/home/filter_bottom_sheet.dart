import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/services/lookup_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/car_enums.dart';
import '../../bloc/car/car_bloc.dart';
import '../../bloc/car/car_event.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialBrand;
  final String? initialModel;

  const FilterBottomSheet({
    super.key,
    this.initialBrand,
    this.initialModel,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {

  final _lookupService = GetIt.I<LookupService>();



  late String? _selectedBrand;

  late String? _selectedModel;

  String? _selectedCity;

  TransmissionType? _selectedTransmission;

  SteeringType? _selectedSteering;

  BodyType? _selectedBodyType;

    String? _selectedColor;

    int? _minYear;

    int? _maxYear;

    int? _minMileage;

    int? _maxMileage;

  

    @override

    void initState() {

      super.initState();

      _selectedBrand = widget.initialBrand;

      _selectedModel = widget.initialModel;

    }

  



  @override

  Widget build(BuildContext context) {

    final lookups = _lookupService.data;



        return Container(



          height: MediaQuery.of(context).size.height * 0.85,



          decoration: BoxDecoration(



            color: Theme.of(context).scaffoldBackgroundColor,



            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),



          ),



          padding: const EdgeInsets.all(24),



          child: Column(



            crossAxisAlignment: CrossAxisAlignment.start,



            children: [



              Center(



                child: Container(



                  width: 40, height: 4,



                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),



                ),



              ),



              const SizedBox(height: 24),



              Row(



                mainAxisAlignment: MainAxisAlignment.spaceBetween,



                children: [



                  const Text('Filtreleme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),



                  TextButton(



                    onPressed: _resetFilters,



                    child: const Text('Temizle', style: TextStyle(color: AppColors.primary)),



                  ),



                ],



              ),

          const SizedBox(height: 16),

          Expanded(

            child: SingleChildScrollView(

              physics: const BouncingScrollPhysics(),

              child: Column(

                children: [


                                _buildDropdown<String>(
                                  label: 'Şehir',
                                  value: _selectedCity,
                                  items: lookups.cities.map((e) => DropdownMenuItem(value: e.value, child: Text(e.labelTr))).toList(),
                                  onChanged: (v) => setState(() => _selectedCity = v),
                                  icon: Icons.location_on_outlined,
                                ),
                                const SizedBox(height: 16),
            
                  _buildDropdown<TransmissionType>(
                    label: 'Vites Türü',
                    value: _selectedTransmission,
                    items: TransmissionType.values.map((e) {
                      String label = e == TransmissionType.manual ? 'Manuel' : (e == TransmissionType.automatic ? 'Otomatik' : 'Yarı Otomatik');
                      return DropdownMenuItem(value: e, child: Text(label));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedTransmission = v),
                    icon: Icons.settings_input_component_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown<SteeringType>(
                    label: 'Direksiyon Yönü',
                    value: _selectedSteering,
                    items: SteeringType.values.map((e) {
                      String label = e == SteeringType.right ? 'Sağ Direksiyon' : 'Sol Direksiyon';
                      return DropdownMenuItem(value: e, child: Text(label));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedSteering = v),
                    icon: Icons.directions_car_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown<BodyType>(
                    label: 'Kasa Tipi',
                    value: _selectedBodyType,
                    items: lookups.bodyTypes.map((e) {
                      BodyType type = BodyType.values.firstWhere((bt) => bt.name == e.value.replaceAll('-', ''), orElse: () => BodyType.sedan);
                      return DropdownMenuItem(value: type, child: Text(e.labelTr));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedBodyType = v),
                    icon: Icons.directions_car_filled_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown<String>(
                    label: 'Renk',
                    value: _selectedColor,
                    items: lookups.colors.map((e) => DropdownMenuItem(value: e.value, child: Text(e.labelTr))).toList(),
                    onChanged: (v) => setState(() => _selectedColor = v),
                    icon: Icons.palette_outlined,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<int>(
                          label: 'Min Yıl',
                          value: _minYear,
                          items: List.generate(30, (index) => 2026 - index).map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                          onChanged: (v) => setState(() => _minYear = v),
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown<int>(
                          label: 'Max Yıl',
                          value: _maxYear,
                          items: List.generate(30, (index) => 2026 - index).map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                          onChanged: (v) => setState(() => _maxYear = v),
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<int>(
                          label: 'Minimum KM',
                          value: _minMileage,
                          items: [0, 10000, 30000, 50000, 100000, 150000, 200000]
                              .map((e) => DropdownMenuItem(value: e, child: Text('${e.toString()} KM'))).toList(),
                          onChanged: (v) => setState(() => _minMileage = v),
                          icon: Icons.speed_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown<int>(
                          label: 'Maksimum KM',
                          value: _maxMileage,
                          items: [10000, 30000, 50000, 100000, 150000, 200000, 300000, 500000]
                              .map((e) => DropdownMenuItem(value: e, child: Text('${e.toString()} KM'))).toList(),
                          onChanged: (v) => setState(() => _maxMileage = v),
                          icon: Icons.speed_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Filtreleri Uygula', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
              hint: Text('Seçiniz', style: TextStyle(color: AppColors.textHint.withOpacity(0.5))),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedBrand = null;
      _selectedModel = null;
      _selectedCity = null;
      _selectedTransmission = null;
      _selectedSteering = null;
      _selectedBodyType = null;
      _selectedColor = null;
      _minYear = null;
      _maxYear = null;
      _minMileage = null;
      _maxMileage = null;
    });
  }

  void _applyFilters() {
    context.read<CarBloc>().add(GetCarsEvent(
      brand: _selectedBrand,
      model: _selectedModel,
      city: _selectedCity,
      transmission: _selectedTransmission,
      steering: _selectedSteering,
      bodyType: _selectedBodyType,
      color: _selectedColor,
      minYear: _minYear,
      maxYear: _maxYear,
      minMileage: _minMileage,
      maxMileage: _maxMileage,
      page: 1,
      limit: 20,
      sortBy: 'created_at',
      sortOrder: 'desc',
    ));
    Navigator.pop(context);
  }
}
