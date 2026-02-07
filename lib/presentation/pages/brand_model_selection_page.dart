import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/brand_entity.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';

class BrandModelSelectionPage extends StatefulWidget {
  const BrandModelSelectionPage({super.key});

  @override
  State<BrandModelSelectionPage> createState() => _BrandModelSelectionPageState();
}

class _BrandModelSelectionPageState extends State<BrandModelSelectionPage> {
  BrandEntity? _selectedBrand;
  SeriesModels? _selectedSeries;
  String? _selectedModel;

  List<BrandEntity> _brands = [];
  List<SeriesModels> _seriesModels = [];
  List<String> _models = [];

  @override
  void initState() {
    super.initState();
    context.read<CarBloc>().add(const GetAllBrandsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Araç Seçimi'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: BlocConsumer<CarBloc, CarState>(
        listener: (context, state) {
          if (state is AllBrandsLoaded) {
            setState(() => _brands = state.brands);
          } else if (state is SeriesAndModelsLoaded) {
            setState(() {
              _seriesModels = state.seriesModels;
              _selectedSeries = null;
              _selectedModel = null;
              _models = [];
            });
          } else if (state is CarError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown<BrandEntity>(
                  label: 'Marka Seçin',
                  value: _selectedBrand,
                  items: _brands.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                  onChanged: (brand) {
                    setState(() {
                      _selectedBrand = brand;
                      _selectedSeries = null;
                      _selectedModel = null;
                      _seriesModels = [];
                      _models = [];
                    });
                    if (brand != null) {
                      context.read<CarBloc>().add(GetSeriesAndModelsEvent(brandId: brand.id));
                    }
                  },
                  hint: 'Marka seçin',
                ),
                const SizedBox(height: 20),
                _buildDropdown<SeriesModels>(
                  label: 'Seri Seçin',
                  value: _selectedSeries,
                  items: _seriesModels.map((s) => DropdownMenuItem(value: s, child: Text(s.series))).toList(),
                  onChanged: _selectedBrand == null ? null : (series) {
                    setState(() {
                      _selectedSeries = series;
                      _selectedModel = null;
                      _models = series?.models ?? [];
                    });
                  },
                  hint: _selectedBrand == null ? 'Önce marka seçin' : 'Seri seçin',
                ),
                const SizedBox(height: 20),
                _buildDropdown<String>(
                  label: 'Model Seçin',
                  value: _selectedModel,
                  items: _models.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: _selectedSeries == null ? null : (model) {
                    setState(() => _selectedModel = model);
                  },
                  hint: _selectedSeries == null ? 'Önce seri seçin' : 'Model seçin',
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_selectedBrand != null && _selectedSeries != null && _selectedModel != null)
                        ? () {
                            Navigator.of(context).pop({
                              'brand': _selectedBrand!.name,
                              'series': _selectedSeries!.series,
                              'model': _selectedModel
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('UYGULA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required String hint,
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
              hint: Text(hint, style: TextStyle(color: AppColors.textHint.withOpacity(0.5))),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
