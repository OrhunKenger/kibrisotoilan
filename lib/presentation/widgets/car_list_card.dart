import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/enum_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/ui_helpers.dart';
import '../../domain/entities/car_entity.dart';

class CarListCard extends StatefulWidget {
  final CarEntity car;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const CarListCard({
    super.key,
    required this.car,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  State<CarListCard> createState() => _CarListCardState();
}

class _CarListCardState extends State<CarListCard> {
  DisplayCurrency _displayCurrency = DisplayCurrency.gbp;

  @override
  void initState() {
    super.initState();
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 160,
              width: double.infinity,
              color: AppColors.surfaceLight,
              child: Stack(
                children: [
                  if (widget.car.imageUrls.isNotEmpty)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: widget.car.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 48, color: AppColors.textDisabled),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_car, size: 48, color: AppColors.textDisabled),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.car.brand} ${widget.car.model}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  // Favorite button
                  if (widget.onFavorite != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: widget.onFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: widget.isFavorite ? Colors.red : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  // Urgent/Featured badges
                  if (widget.car.isUrgent || widget.car.isFeatured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          if (widget.car.isUrgent)
                            _buildTopBadge('Acil', AppColors.error),
                          if (widget.car.isUrgent && widget.car.isFeatured)
                            const SizedBox(width: 4),
                          if (widget.car.isFeatured)
                            _buildTopBadge('Öne Çıkan', AppColors.warning),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.car.title,
                    style: AppTextStyles.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.car.brand} ${widget.car.model} - ${widget.car.year}',
                    style: AppTextStyles.caption.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        UIHelpers.formatPriceWithConversion(
                          widget.car.price,
                          originalCurrency: widget.car.currency,
                          displayCurrency: _displayCurrency,
                          gbpToTryRate: widget.car.exchangeRates?.gbpToTry ?? 42.0,
                        ),
                        style: AppTextStyles.price,
                      ),
                      const SizedBox(width: 8),
                      _buildCurrencyToggle(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildBadge(EnumLabels.transmission[widget.car.transmission] ?? '', Icons.settings),
                      _buildBadge(EnumLabels.bodyType[widget.car.bodyType] ?? '', Icons.directions_car_filled_outlined),
                      if (widget.car.fuelType != null)
                        _buildBadge(EnumLabels.fuelType(widget.car.fuelType), Icons.local_gas_station),
                      _buildBadge(
                        '${EnumLabels.steering[widget.car.steering]} Dir.',
                        Icons.swap_horiz,
                      ),
                      if (widget.car.isExchangeable)
                        _buildBadge('Takas', Icons.swap_horizontal_circle, highlight: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        widget.car.district != null ? '${widget.car.city}, ${widget.car.district}' : widget.car.city,
                        style: AppTextStyles.caption,
                      ),
                      const Spacer(),
                      const Icon(Icons.speed, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${UIHelpers.formatMileage(widget.car.mileage)} ${EnumLabels.mileageUnit[widget.car.mileageUnit] ?? 'KM'}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyToggle() {
    return InkWell(
      onTap: _toggleCurrency,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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

  Widget _buildTopBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: highlight
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: highlight ? AppColors.primary : AppColors.textHint),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(
              color: highlight ? AppColors.primary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

}
