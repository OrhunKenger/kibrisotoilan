import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/enum_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/ui_helpers.dart';
import '../../domain/entities/car_entity.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';
import '../widgets/error_state_widget.dart';

class CarDetailPage extends StatefulWidget {
  final int carId;

  const CarDetailPage({super.key, required this.carId});

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  DisplayCurrency _displayCurrency = DisplayCurrency.gbp;

  @override
  void initState() {
    super.initState();
    context.read<CarBloc>().add(GetCarDetailEvent(carId: widget.carId));
    _loadCurrencyPreference();
  }

  Future<void> _loadCurrencyPreference() async {
    final currency = await UIHelpers.getDisplayCurrency();
    if (mounted) {
      setState(() {
        _displayCurrency = currency;
      });
    }
  }

  Future<void> _toggleCurrency() async {
    final newCurrency = _displayCurrency == DisplayCurrency.gbp
        ? DisplayCurrency.try_
        : DisplayCurrency.gbp;
    await UIHelpers.setDisplayCurrency(newCurrency);
    if (mounted) {
      setState(() {
        _displayCurrency = newCurrency;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CarBloc, CarState>(
        listener: (context, state) {
          if (state is FavoriteToggled) {
            setState(() {
              _isFavorite = state.isFavorite;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.isFavorite ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is FavoriteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        buildWhen: (_, current) =>
            current is CarLoading || current is CarDetailLoaded || current is CarError,
        builder: (context, state) {
          if (state is CarLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is CarDetailLoaded) {
            return _buildDetailView(state.car);
          } else if (state is CarError) {
            return Scaffold(
              appBar: AppBar(title: const Text('İlan Detayı')),
              body: ErrorStateWidget(
                message: state.message,
                onRetry: () => context.read<CarBloc>().add(
                      GetCarDetailEvent(carId: widget.carId),
                    ),
              ),
            );
          }
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  Widget _buildDetailView(CarEntity car) {
    return CustomScrollView(
      slivers: [
        // App bar with image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: car.imageUrls.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: car.imageUrls.length,
                        onPageChanged: (i) => setState(() => _currentImageIndex = i),
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: car.imageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.surfaceLight,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceLight,
                              child: const Icon(Icons.broken_image, size: 48, color: AppColors.textHint),
                            ),
                          );
                        },
                      ),
                      if (car.imageUrls.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(car.imageUrls.length, (i) {
                              return Container(
                                width: _currentImageIndex == i ? 10 : 7,
                                height: _currentImageIndex == i ? 10 : 7,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == i
                                      ? AppColors.primary
                                      : Colors.white54,
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  )
                : Container(
                    color: AppColors.surfaceLight,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_car, size: 80, color: AppColors.textDisabled),
                          const SizedBox(height: 8),
                          Text('${car.brand} ${car.model}', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () {
                if (_isFavorite) {
                  context.read<CarBloc>().add(RemoveFavoriteEvent(carId: car.id!));
                } else {
                  context.read<CarBloc>().add(AddFavoriteEvent(carId: car.id!));
                }
              },
            ),
          ],
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Price
                Text(car.title, style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      UIHelpers.formatPriceWithConversion(
                        car.price,
                        originalCurrency: car.currency,
                        displayCurrency: _displayCurrency,
                        gbpToTryRate: car.exchangeRates?.gbpToTry ?? 42.0,
                      ),
                      style: AppTextStyles.price.copyWith(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    _buildCurrencyToggle(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${car.brand} ${car.model} - ${car.year}',
                  style: AppTextStyles.bodySecondary,
                ),

                const SizedBox(height: 20),

                // Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (car.isUrgent) _buildStatusChip('Acil', AppColors.error),
                    if (car.isFeatured) _buildStatusChip('Öne Çıkan', AppColors.warning),
                    if (car.isExchangeable) _buildStatusChip('Takas Olur', AppColors.primary),
                  ],
                ),

                const SizedBox(height: 24),

                // Specs grid
                _buildSectionTitle('Teknik Bilgiler'),
                const SizedBox(height: 12),
                _buildSpecsGrid(car),

                const SizedBox(height: 24),

                // Location
                _buildSectionTitle('Konum'),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.location_on,
                  car.district != null ? '${car.city}, ${car.district}' : car.city,
                ),

                // Description
                if (car.description != null && car.description!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Açıklama'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(car.description!, style: AppTextStyles.body),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.sectionTitle);
  }

  Widget _buildSpecsGrid(CarEntity car) {
    final specs = <_SpecItem>[
      _SpecItem(Icons.settings, 'Vites', EnumLabels.transmission[car.transmission] ?? ''),
      _SpecItem(Icons.directions_car_filled_outlined, 'Kasa', EnumLabels.bodyType[car.bodyType] ?? ''),
      _SpecItem(Icons.swap_horiz, 'Direksiyon', car.steeringSide),
      _SpecItem(Icons.speed, 'Kilometre', '${UIHelpers.formatMileage(car.mileage)} ${EnumLabels.mileageUnit[car.mileageUnit] ?? 'KM'}'),
      _SpecItem(Icons.engineering, 'Motor', '${car.engineSize} cc'),
      if (car.fuelType != null)
        _SpecItem(Icons.local_gas_station, 'Yakıt', EnumLabels.fuelType(car.fuelType)),
      _SpecItem(Icons.palette, 'Renk', car.color),
      _SpecItem(Icons.calendar_today, 'Yıl', '${car.year}'),
      _SpecItem(Icons.policy_outlined, 'Kayıt', car.registrationStatus),
      if (car.licenseSeries != null)
        _SpecItem(Icons.label_important_outline, 'Plaka Serisi', car.licenseSeries!),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        final spec = specs[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(spec.icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(spec.label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    Text(spec.value, style: AppTextStyles.body.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Chip(
      label: Text(label, style: AppTextStyles.badge.copyWith(color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCurrencyToggle() {
    return InkWell(
      onTap: _toggleCurrency,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha:0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '£',
              style: TextStyle(
                fontWeight: _displayCurrency == DisplayCurrency.gbp
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _displayCurrency == DisplayCurrency.gbp
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
            ),
            const Text(' / ', style: TextStyle(color: AppColors.textHint)),
            Text(
              '₺',
              style: TextStyle(
                fontWeight: _displayCurrency == DisplayCurrency.try_
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _displayCurrency == DisplayCurrency.try_
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String label;
  final String value;
  const _SpecItem(this.icon, this.label, this.value);
}
