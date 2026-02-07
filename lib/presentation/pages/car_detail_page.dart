import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/entities/car_enums.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/utils/ui_helpers.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';

class CarDetailPage extends StatefulWidget {
  final CarEntity car;

  const CarDetailPage({super.key, required this.car});

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  late CarEntity _currentCar;
  int _currentImageIndex = 0;
  DisplayCurrency _displayCurrency = DisplayCurrency.gbp;

  @override
  void initState() {
    super.initState();
    _currentCar = widget.car;
    _loadCurrency();
    // Sayfa açılır açılmaz detayı çek (görüntüleme sayısını backend'de artırır)
    context.read<CarBloc>().add(GetCarDetailEvent(carId: _currentCar.id!));
  }

  Future<void> _loadCurrency() async {
    final cur = await UIHelpers.getDisplayCurrency();
    if (mounted) setState(() => _displayCurrency = cur);
  }

  Future<void> _toggleCurrency() async {
    final newCur = _displayCurrency == DisplayCurrency.gbp ? DisplayCurrency.try_ : DisplayCurrency.gbp;
    await UIHelpers.setDisplayCurrency(newCur);
    if (mounted) setState(() => _displayCurrency = newCur);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarBloc, CarState>(
      listener: (context, state) {
        if (state is CarDetailLoaded) {
          setState(() => _currentCar = state.car);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildMainContent(),
            _buildCustomAppBar(),
            _buildBottomActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndPrice(),
                const SizedBox(height: 16),
                
                // Görüntüleme Sayısı Bölümü (HERKES GÖREBİLİR)
                _buildViewsBanner(),
                const SizedBox(height: 24),

                _buildQuickSpecs(),
                const SizedBox(height: 32),
                const Text('İlan Açıklaması', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  _currentCar.description ?? 'Açıklama belirtilmemiş.',
                  style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 32),
                _buildDetailsTable(),
                const SizedBox(height: 32),
                _buildSellerCard(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Bu ilan ',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
          Text(
            '${_currentCar.viewsCount}',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            ' kez görüntülendi',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAppBarButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
          _buildAppBarButton(Icons.favorite_border, () {}),
        ],
      ),
    );
  }

  Widget _buildAppBarButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = _currentCar.imageUrls;
    return Stack(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, index) {
              return Hero(
                tag: 'car_${_currentCar.id}',
                child: CachedNetworkImage(
                  imageUrl: images.isNotEmpty ? images[index] : 'https://via.placeholder.com/600x400',
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(color: AppColors.surface, child: const Center(child: CircularProgressIndicator())),
                  errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentImageIndex == index ? 24 : 6,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index ? AppColors.primary : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleAndPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text(_currentCar.brand, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            Text('İlan No: #${_currentCar.id}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Text(_currentCar.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text('${_currentCar.city}, ${_currentCar.district ?? ''}', style: const TextStyle(color: AppColors.textHint)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              UIHelpers.formatPriceWithConversion(
                _currentCar.price,
                originalCurrency: _currentCar.currency,
                displayCurrency: _displayCurrency,
                gbpToTryRate: _currentCar.exchangeRates?.gbpToTry,
              ),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _toggleCurrency,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  _displayCurrency == DisplayCurrency.gbp ? '£→₺' : '₺→£',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickSpecs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSpecIcon(Icons.calendar_today, '${_currentCar.year}', 'Model'),
        _buildSpecIcon(Icons.speed, '${_currentCar.mileage} ${_currentCar.mileageUnit.name.toUpperCase()}', 'Kilometre'),
        _buildSpecIcon(Icons.settings_outlined, UIHelpers.translateTransmission(_currentCar.transmission), 'Vites'),
        _buildSpecIcon(Icons.local_gas_station_outlined, UIHelpers.translateFuelType(_currentCar.fuelType), 'Yakıt'),
      ],
    );
  }

  Widget _buildSpecIcon(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
      ],
    );
  }

  Widget _buildDetailsTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildDetailRow('Marka / Model', '${_currentCar.brand} / ${_currentCar.model}'),
          _buildDetailRow('Direksiyon', UIHelpers.translateSteering(_currentCar.steering)),
          _buildDetailRow('Motor Hacmi', '${_currentCar.engineSize} cc'),
          _buildDetailRow('Renk', _currentCar.color),
          _buildDetailRow('Kayıt Durumu', _currentCar.registrationStatus, isLast: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textHint)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSellerCard() {
    final owner = _currentCar.owner;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: owner?.profileImageUrl != null ? NetworkImage(owner!.profileImageUrl!) : null,
            child: owner?.profileImageUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(owner?.fullName ?? 'Bilinmeyen Satıcı', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(owner?.companyName ?? 'Bireysel Satıcı', style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
              ],
            ),
          ),
          if (owner?.isVerified == true)
            const Icon(Icons.verified, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    final owner = _currentCar.owner;
    final bool hasPhone = owner?.phoneNumber != null && owner!.phoneNumber!.isNotEmpty;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.9),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: hasPhone ? () => launchUrl(Uri.parse('tel:${owner!.phoneNumber}')) : null,
                icon: const Icon(Icons.phone),
                label: const Text('Hemen Ara'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(15)),
              child: IconButton(
                onPressed: hasPhone ? () => launchUrl(Uri.parse('https://wa.me/${owner!.phoneNumber}'), mode: LaunchMode.externalApplication) : null,
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
