import 'package:flutter/material.dart';
import '../../core/services/brand_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../injection_container.dart' as di;

class BrandModelSelection {
  final String brand;
  final String series;
  final String model;

  const BrandModelSelection({
    required this.brand,
    required this.series,
    required this.model,
  });
}

Future<BrandModelSelection?> showBrandModelPicker(BuildContext context) async {
  final brandService = di.sl<BrandService>();

  // Step 1: Pick a brand
  final brand = await showModalBottomSheet<BrandInfo>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BrandPickerSheet(brandService: brandService),
  );
  if (brand == null) return null;

  // Step 2: Pick a model for that brand
  if (!context.mounted) return null;
  final selection = await showModalBottomSheet<BrandModelSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ModelPickerSheet(
      brandService: brandService,
      brand: brand,
    ),
  );
  return selection;
}

class _BrandPickerSheet extends StatefulWidget {
  final BrandService brandService;
  const _BrandPickerSheet({required this.brandService});

  @override
  State<_BrandPickerSheet> createState() => _BrandPickerSheetState();
}

class _BrandPickerSheetState extends State<_BrandPickerSheet> {
  late Future<List<BrandInfo>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.brandService.loadBrands();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Marka Sec', style: AppTextStyles.heading3),
              ),
              const Divider(color: AppColors.divider, height: 1),
              Expanded(
                child: FutureBuilder<List<BrandInfo>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    final brands = snapshot.data ?? [];
                    if (brands.isEmpty) {
                      return Center(
                        child: Text('Marka bulunamadi', style: AppTextStyles.bodySecondary),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: brands.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: AppColors.divider, height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final brand = brands[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surfaceLight,
                            child: Text(
                              brand.name[0],
                              style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
                            ),
                          ),
                          title: Text(brand.name, style: AppTextStyles.body),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                          onTap: () => Navigator.of(context).pop(brand),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModelPickerSheet extends StatefulWidget {
  final BrandService brandService;
  final BrandInfo brand;
  const _ModelPickerSheet({required this.brandService, required this.brand});

  @override
  State<_ModelPickerSheet> createState() => _ModelPickerSheetState();
}

class _ModelPickerSheetState extends State<_ModelPickerSheet> {
  late Future<List<SeriesGroup>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = widget.brandService.loadModels(widget.brand.id);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${widget.brand.name} - Model Sec',
                  style: AppTextStyles.heading3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  style: AppTextStyles.input,
                  decoration: InputDecoration(
                    hintText: 'Ara...',
                    hintStyle: AppTextStyles.hint,
                    prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: AppColors.divider, height: 1),
              Expanded(
                child: FutureBuilder<List<SeriesGroup>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    final groups = snapshot.data ?? [];
                    if (groups.isEmpty) {
                      return Center(
                        child: Text('Model bulunamadi', style: AppTextStyles.bodySecondary),
                      );
                    }

                    // Build flat list of tappable items filtered by search
                    final items = <_ModelItem>[];
                    for (final group in groups) {
                      final filteredModels = group.models
                          .where((m) =>
                              _search.isEmpty ||
                              m.toLowerCase().contains(_search) ||
                              group.series.toLowerCase().contains(_search))
                          .toList();
                      if (filteredModels.isNotEmpty) {
                        items.add(_ModelItem(series: group.series, model: null, isHeader: true));
                        for (final model in filteredModels) {
                          items.add(_ModelItem(series: group.series, model: model, isHeader: false));
                        }
                      }
                    }

                    if (items.isEmpty) {
                      return Center(
                        child: Text('Sonuc bulunamadi', style: AppTextStyles.bodySecondary),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        if (item.isHeader) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Text(
                              item.series,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                          title: Text(item.model!, style: AppTextStyles.body),
                          onTap: () {
                            Navigator.of(context).pop(BrandModelSelection(
                              brand: widget.brand.name,
                              series: item.series,
                              model: item.model!,
                            ));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModelItem {
  final String series;
  final String? model;
  final bool isHeader;
  const _ModelItem({required this.series, this.model, required this.isHeader});
}
