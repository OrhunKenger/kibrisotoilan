import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';

class BrandModelSelectionPage extends StatefulWidget {
  const BrandModelSelectionPage({super.key});

  @override
  State<BrandModelSelectionPage> createState() => _BrandModelSelectionPageState();
}

class _BrandModelSelectionPageState extends State<BrandModelSelectionPage> {
  String? _selectedBrand;
  String? _selectedModel;
  List<String> _brands = [];
  List<String> _models = [];

  @override
  void initState() {
    super.initState();
    context.read<CarBloc>().add(const GetUniqueBrandsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marka ve Model Seçimi'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: BlocConsumer<CarBloc, CarState>(
        listener: (context, state) {
          if (state is CarBrandsLoaded) {
            setState(() {
              _brands = state.brands;
            });
          } else if (state is CarModelsLoaded) {
            setState(() {
              _models = state.models;
              // Reset selected model if the current one is not in the new list
              if (_selectedModel != null && !_models.contains(_selectedModel)) {
                _selectedModel = null;
              }
            });
          } else if (state is CarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CarLoading && (_brands.isEmpty || _models.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marka Seçin',
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  decoration: InputDecoration(
                    hintText: 'Marka',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: AppColors.surface,
                  style: AppTextStyles.input.copyWith(color: AppColors.textPrimary),
                  items: _brands.map((brand) => DropdownMenuItem(value: brand, child: Text(brand))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                      _selectedModel = null; // Reset model when brand changes
                      if (value != null) {
                        context.read<CarBloc>().add(GetModelsByBrandEvent(brand: value));
                      } else {
                        _models = []; // Clear models if no brand is selected
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Model Seçin',
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedModel,
                  decoration: InputDecoration(
                    hintText: 'Model',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: AppColors.surface,
                  style: AppTextStyles.input.copyWith(color: AppColors.textPrimary),
                  items: _models.map((model) => DropdownMenuItem(value: model, child: Text(model))).toList(),
                  onChanged: (_selectedBrand != null)
                      ? (value) {
                    setState(() {
                      _selectedModel = value;
                    });
                  }
                      : null,
                  // Disable model selection if no brand is selected
                  // isEnabled: _selectedBrand != null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedBrand != null && _selectedModel != null)
                        ? () {
                      Navigator.of(context).pop({'brand': _selectedBrand, 'model': _selectedModel});
                    }
                        : null, // Disable button if brand or model not selected
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      textStyle: AppTextStyles.button,
                    ),
                    child: const Text('Uygula ve Filtrele'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
