import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/car_entity.dart';
import '../../../core/utils/ui_helpers.dart';

class CarCard extends StatelessWidget {

  final CarEntity car;

  final VoidCallback onTap;

  final DisplayCurrency displayCurrency;



  const CarCard({

    super.key,

    required this.car,

    required this.onTap,

    this.displayCurrency = DisplayCurrency.gbp,

  });



  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        decoration: BoxDecoration(

          color: AppColors.surface, // Use AppColors consistently

          borderRadius: BorderRadius.circular(16),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withOpacity(0.1),

              blurRadius: 10,

              offset: const Offset(0, 4),

            ),

          ],

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // Resim Alanı

            Expanded(

              flex: 5,

              child: Stack(

                children: [

                  ClipRRect(

                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),

                    child: Hero(

                      tag: 'car_${car.id}',

                      child: CachedNetworkImage(

                        imageUrl: car.imageUrls.isNotEmpty 

                            ? car.imageUrls.first 

                            : 'https://via.placeholder.com/300x200.png?text=No+Image',

                        fit: BoxFit.cover,

                        width: double.infinity,

                        height: double.infinity,

                        placeholder: (context, url) => Container(

                          color: AppColors.surface,

                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),

                        ),

                        errorWidget: (context, url, error) => Container(

                          color: AppColors.surface,

                          child: const Icon(Icons.broken_image, color: AppColors.textHint),

                        ),

                      ),

                    ),

                  ),

                  Positioned(

                    top: 8,

                    left: 8,

                    child: Container(

                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                      decoration: BoxDecoration(

                        color: Colors.black.withOpacity(0.6),

                        borderRadius: BorderRadius.circular(8),

                      ),

                      child: Text(

                        '${car.year}',

                        style: const TextStyle(

                          color: Colors.white,

                          fontSize: 10,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                    ),

                  ),

                ],

              ),

            ),

            

            // Bilgi Alanı

            Expanded(

              flex: 4,

              child: Padding(

                padding: const EdgeInsets.all(12),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [

                    Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          '${car.brand} ${car.model}',

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(

                            fontSize: 14,

                            fontWeight: FontWeight.bold,

                            color: AppColors.textPrimary,

                          ),

                        ),

                        const SizedBox(height: 4),

                        Text(

                          car.title,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(

                            fontSize: 11,

                            color: AppColors.textHint,

                          ),

                        ),

                      ],

                    ),

                    

                    Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          UIHelpers.formatPriceWithConversion(

                            car.price,

                            originalCurrency: car.currency,

                            displayCurrency: displayCurrency,

                            gbpToTryRate: car.exchangeRates?.gbpToTry,

                          ),

                          style: const TextStyle(

                            fontSize: 15,

                            fontWeight: FontWeight.bold,

                            color: AppColors.primary,

                          ),

                        ),

                        const SizedBox(height: 4),

                        Row(

                          children: [

                            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textHint),

                            const SizedBox(width: 2),

                            Text(

                              car.city,

                              style: const TextStyle(fontSize: 10, color: AppColors.textHint),

                            ),

                          ],

                        ),

                      ],

                    ),

                  ],

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}
