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
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim Alanı
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  if (widget.car.imageUrls.isNotEmpty)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: widget.car.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.surfaceLight, child: const Center(child: CircularProgressIndicator())),
                        errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 48)),
                      ),
                    )
                  else
                    Container(color: AppColors.surfaceLight, child: const Center(child: Icon(Icons.directions_car, size: 48))),
                  
                  // Etiketler (Acil / Öne Çıkan)
                  if (widget.car.isUrgent || widget.car.isFeatured)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        children: [
                          if (widget.car.isUrgent) _buildTopBadge('Acil', AppColors.error),
                          if (widget.car.isUrgent && widget.car.isFeatured) const SizedBox(width: 4),
                          if (widget.car.isFeatured) _buildTopBadge('Öne Çıkan', AppColors.warning),
                        ],
                      ),
                    ),
                  
                  // Favori Butonu
                  if (widget.onFavorite != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: widget.onFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                          child: Icon(widget.isFavorite ? Icons.favorite : Icons.favorite_border, color: widget.isFavorite ? Colors.red : Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Bilgi Alanı
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.car.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Görüntüleme Sayısı (YENİ)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.remove_red_eye, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.car.viewsCount}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.car.brand} ${widget.car.model} • ${widget.car.year}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            UIHelpers.formatPriceWithConversion(
                              widget.car.price,
                              originalCurrency: widget.car.currency,
                              displayCurrency: _displayCurrency,
                              gbpToTryRate: widget.car.exchangeRates?.gbpToTry,
                            ),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          _buildCurrencyToggle(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        widget.car.district != null ? '${widget.car.city}, ${widget.car.district}' : widget.car.city,
                        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                      ),
                      const Spacer(),
                      const Icon(Icons.speed, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${UIHelpers.formatMileage(widget.car.mileage)} ${EnumLabels.mileageUnit[widget.car.mileageUnit] ?? 'KM'}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          _displayCurrency == DisplayCurrency.gbp ? '£→₺' : '₺→£',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildTopBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}