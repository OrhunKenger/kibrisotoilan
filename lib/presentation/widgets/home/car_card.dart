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

            

                                      ),

            

                                    ),

            

                                    const SizedBox(height: 2),

            

                                    Text(

            

                                      car.title,

            

                                      maxLines: 1,

            

                                      overflow: TextOverflow.ellipsis,

            

                                      style: TextStyle(

            

                                        fontSize: 10,

            

                                        color: Theme.of(context).hintColor,

            

                                      ),

            

                                    ),

            

                                    const SizedBox(height: 4),

            

                                    Row(

            

                                      children: [

            

                                        _buildInfoBadge(context, UIHelpers.translateTransmission(car.transmission)),

            

                                        const SizedBox(width: 4),

            

                                        _buildInfoBadge(context, '${UIHelpers.formatMileage(car.mileage)} ${car.mileageUnit.name.toUpperCase()}'),

            

                                      ],

            

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

            

                                        Icon(Icons.location_on_outlined, size: 12, color: Theme.of(context).hintColor),

            

                                        const SizedBox(width: 2),

            

                                        Text(

            

                                          car.city,

            

                                          style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),

            

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

            

            

            

              Widget _buildInfoBadge(BuildContext context, String text) {

            

                return Container(

            

                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),

            

                  decoration: BoxDecoration(

            

                    color: AppColors.primary.withOpacity(0.1),

            

                    borderRadius: BorderRadius.circular(4),

            

                  ),

            

                  child: Text(

            

                    text,

            

                    style: const TextStyle(

            

                      fontSize: 8,

            

                      color: AppColors.primary,

            

                      fontWeight: FontWeight.bold,

            

                    ),

            

                  ),

            

                );

            

              }

            

            }
