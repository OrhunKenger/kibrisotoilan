import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/entities/car_enums.dart';
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildPriceSection(),
                const SizedBox(height: 32),
                _buildQuickSpecs(),
                const SizedBox(height: 32),
                _buildSectionTitle('Teknik Detaylar'),
                const SizedBox(height: 16),
                _buildDetailsTable(),
                const SizedBox(height: 32),
                _buildSectionTitle('Açıklama'),
                const SizedBox(height: 12),
                Text(
                  _currentCar.description ?? 'Açıklama belirtilmemiş.',
                  style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.6),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Satıcı Bilgileri'),
                const SizedBox(height: 16),
                _buildSellerCard(),
                const SizedBox(height: 140),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
              child: Text(_currentCar.brand, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
            ),
            const SizedBox(width: 10),
            Text('İlan #${_currentCar.id}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('${_currentCar.viewsCount}', style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _currentCar.model,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          _currentCar.title,
          style: const TextStyle(fontSize: 16, color: AppColors.textHint, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('${_currentCar.city} / ${_currentCar.district ?? ''}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SATIŞ FİYATI', style: TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(
                UIHelpers.formatPriceWithConversion(
                  _currentCar.price,
                  originalCurrency: _currentCar.currency,
                  displayCurrency: _displayCurrency,
                  gbpToTryRate: _currentCar.exchangeRates?.gbpToTry,
                ),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
          _buildCurrencyToggle(),
        ],
      ),
    );
  }

  Widget _buildCurrencyToggle() {
    return GestureDetector(
      onTap: _toggleCurrency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Text(
          _displayCurrency == DisplayCurrency.gbp ? 'TL\'ye Çevir' : '£\'e Çevir',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildQuickSpecs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSpecItem(Icons.calendar_today_outlined, '${_currentCar.year}', 'Model Yılı'),
        _buildSpecItem(Icons.speed, '${_currentCar.mileage} ${_currentCar.mileageUnit.name.toUpperCase()}', 'Kilometre'),
        _buildSpecItem(Icons.settings_input_component_outlined, UIHelpers.translateTransmission(_currentCar.transmission), 'Vites'),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDetailsTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildDetailRow('Yakıt Tipi', UIHelpers.translateFuelType(_currentCar.fuelType)),
          _buildDetailRow('Kasa Tipi', UIHelpers.translateBodyType(_currentCar.bodyType)),
          _buildDetailRow('Motor Hacmi', '${_currentCar.engineSize} cc'),
          _buildDetailRow('Renk', _currentCar.color),
          _buildDetailRow('Direksiyon', _currentCar.steeringSide),
          _buildDetailRow('Kayıt Durumu', _currentCar.registrationStatus),
          _buildDetailRow('Plaka Serisi', _currentCar.licenseSeries ?? 'Belirtilmemiş'),
          _buildDetailRow('Takas', _currentCar.isExchangeable ? 'Evet' : 'Hayır', isLast: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = _currentCar.imageUrls;
    return Stack(
      children: [
        SizedBox(
          height: 450,
          width: double.infinity,
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
        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.6)],
                stops: const [0.0, 0.2, 0.7, 1.0],
              ),
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 4,
                  width: _currentImageIndex == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index ? AppColors.primary : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
      ],
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
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5));
  }

  Widget _buildSellerCard() {
    final owner = _currentCar.owner;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: owner?.profileImageUrl != null ? NetworkImage(owner!.profileImageUrl!) : null,
            child: owner?.profileImageUrl == null ? const Icon(Icons.person, color: AppColors.primary, size: 30) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(owner?.fullName ?? 'Bilinmeyen Satıcı', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(owner?.companyName ?? 'Bireysel Satıcı', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
              ],
            ),
          ),
          if (owner?.isVerified == true)
            const Icon(Icons.verified, color: AppColors.primary, size: 22),
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
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.95),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: hasPhone ? () => launchUrl(Uri.parse('tel:${owner!.phoneNumber}')) : null,
                icon: const Icon(Icons.call, size: 20),
                label: const Text('SATICIYI ARA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: const Color(0xFF25D366).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: IconButton(
                onPressed: hasPhone ? () => launchUrl(Uri.parse('https://wa.me/${owner!.phoneNumber}'), mode: LaunchMode.externalApplication) : null,
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                padding: const EdgeInsets.all(18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}