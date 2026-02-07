import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/brand_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';
import '../widgets/home/car_card.dart';
import '../widgets/home/filter_bottom_sheet.dart';
import '../widgets/tools/devir_hesapla_sheet.dart';
import 'car_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BrandEntity? _selectedBrandEntity;
  String? _selectedBrand;
  String? _selectedModel;
  List<SeriesModels> _currentSeriesList = [];

  @override
  void initState() {
    super.initState();
    _checkAndFetch();
  }

  void _checkAndFetch() {
    final carBloc = context.read<CarBloc>();
    if (carBloc.state is CarInitial || carBloc.state is CarError) {
      _fetchCars();
      carBloc.add(const GetAllBrandsEvent());
    }
  }

  void _onBrandTap(BrandEntity brand) {
    if (_selectedBrand == brand.name) {
      _resetBrandFilter();
    } else {
      setState(() {
        _selectedBrandEntity = brand;
        _selectedBrand = brand.name;
        _selectedModel = null;
        _currentSeriesList = [];
      });
      context.read<CarBloc>().add(GetSeriesAndModelsEvent(brandId: brand.id));
      _fetchCars(brand: brand.name);
    }
  }

  void _resetBrandFilter() {
    setState(() {
      _selectedBrandEntity = null;
      _selectedBrand = null;
      _selectedModel = null;
      _currentSeriesList = [];
    });
    _fetchCars(brand: null);
  }

  void _onSeriesTap(String seriesName) {
    setState(() {
      _selectedModel = seriesName;
    });
    _fetchCarsWithSeries(_selectedBrand!, seriesName);
  }

  void _fetchCarsWithSeries(String brand, String series) {
    if (!mounted) return;
    setState(() {
      _selectedBrand = brand;
      _selectedModel = series;
    });
    context.read<CarBloc>().add(GetCarsEvent(
      brand: brand,
      model: series,
      page: 1,
      limit: 20,
      sortBy: 'created_at',
      sortOrder: 'desc',
    ));
  }

  void _fetchCars({String? brand}) {
    if (!mounted) return;
    setState(() {
      _selectedBrand = brand;
      if (brand == null) _selectedModel = null;
    });
    context.read<CarBloc>().add(GetCarsEvent(
      brand: brand,
      model: _selectedModel,
      page: 1,
      limit: 20,
      sortBy: 'created_at',
      sortOrder: 'desc',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _fetchCars(brand: _selectedBrand);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: () async {
            _fetchCars(brand: _selectedBrand);
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildQuickTools()),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: 'Popüler Markalar', 
                  onSeeAll: () => _resetBrandFilter()
                )
              ),
              SliverToBoxAdapter(child: _buildBrandList()),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: _selectedBrand == null ? 'Son Eklenen İlanlar' : '$_selectedBrand İlanları', 
                  onSeeAll: () {}
                )
              ),
              _buildCarGrid(),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: true,
      pinned: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20),
        centerTitle: false,
        title: Row(
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Merhaba,', style: TextStyle(fontSize: 14, color: AppColors.textHint, fontWeight: FontWeight.w400)),
                Text('Kıbrıs Oto İlan', style: TextStyle(fontSize: 20, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => FilterBottomSheet(
                initialBrand: _selectedBrand,
                initialModel: _selectedModel,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hayalindeki aracı bul...', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                    Text('Marka, model veya yıl ara', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTools() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('Hızlı Araçlar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildToolButton(
                  icon: Icons.calculate_outlined,
                  label: 'Devir Hesapla',
                  onTap: () => _showDevirHesaplaOptions(),
                ),
                const SizedBox(width: 12),
                _buildToolButton(
                  icon: Icons.history_edu_outlined,
                  label: 'Hasar Sorgula',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _buildToolButton(
                  icon: Icons.gavel_outlined,
                  label: 'Gümrük Harcı',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDevirHesaplaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const DevirHesaplaOptionsSheet(),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          TextButton(
            onPressed: onSeeAll, 
            child: Text(title == 'Popüler Markalar' ? 'Temizle' : 'Tümü', style: const TextStyle(color: AppColors.primary))
          ),
        ],
      ),
    );
  }

  Widget _buildBrandList() {
    return BlocListener<CarBloc, CarState>(
      listener: (context, state) {
        if (state is SeriesAndModelsLoaded) {
          setState(() => _currentSeriesList = state.seriesModels);
        }
      },
      child: BlocBuilder<CarBloc, CarState>(
        buildWhen: (previous, current) => current is AllBrandsLoaded,
        builder: (context, state) {
          List<BrandEntity> brands = [];
          if (state is AllBrandsLoaded) {
            brands = state.brands;
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildAnimatedContent(brands),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedContent(List<BrandEntity> brands) {
    if (_selectedBrandEntity != null) {
      // Focused View: Selected Brand + Series
      return SizedBox(
        key: const ValueKey('focused_view'),
        height: 100,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildBrandItem(_selectedBrandEntity!, isSelected: true, onTap: () => _resetBrandFilter()),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              width: 1, height: 40, color: Colors.white10,
            ),
            ..._currentSeriesList.map((s) => _buildSeriesItem(s.series, isSelected: _selectedModel == s.series)),
          ],
        ),
      );
    }

    if (brands.isEmpty) {
      return const SizedBox(
        key: ValueKey('loading_view'),
        height: 100,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Default view: All brands
    return SizedBox(
      key: const ValueKey('all_brands_view'),
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) => _buildBrandItem(brands[index], isSelected: false, onTap: () => _onBrandTap(brands[index])),
      ),
    );
  }

  Widget _buildBrandItem(BrandEntity brand, {required bool isSelected, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60, height: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppColors.primary : Colors.white10, width: 2),
            ),
            child: brand.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: brand.logoUrl!,
                    errorWidget: (context, url, error) => Icon(_getBrandIcon(brand.name), color: Colors.black54, size: 30),
                    fit: BoxFit.contain,
                  )
                : Icon(_getBrandIcon(brand.name), color: Colors.black, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(brand.name, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textHint, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }

  Widget _buildSeriesItem(String name, {required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          InkWell(
            onTap: () => _onSeriesTap(name),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 60, height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : Colors.white10, width: 1),
              ),
              child: Center(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textPrimary,
                    fontSize: name.length > 8 ? 9 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Seri', style: TextStyle(color: Colors.transparent, fontSize: 12)),
        ],
      ),
    );
  }

  IconData _getBrandIcon(String brandName) {
    switch (brandName.toLowerCase()) {
      case 'bmw': return Icons.directions_car;
      case 'mercedes-benz': return Icons.stars;
      case 'audi': return Icons.incomplete_circle;
      case 'toyota': return Icons.airport_shuttle;
      case 'honda': return Icons.local_taxi;
      case 'ford': return Icons.commute;
      case 'tesla': return Icons.electric_car;
      default: return Icons.directions_car_filled_outlined;
    }
  }

  Widget _buildCarGrid() {
    return BlocBuilder<CarBloc, CarState>(
      buildWhen: (previous, current) => 
          current is CarsLoaded || current is CarLoading || current is CarInitial || current is CarError,
      builder: (context, state) {
        if (state is CarInitial || state is CarLoading) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
        } else if (state is CarError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: AppColors.textHint)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => _fetchCars(brand: _selectedBrand), child: const Text('Tekrar Dene')),
                ],
              ),
            ),
          );
        } else if (state is CarsLoaded) {
          if (state.cars.isEmpty) {
            return const SliverFillRemaining(child: Center(child: Text('İlan bulunamadı.', style: TextStyle(color: AppColors.textHint))));
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final car = state.cars[index];
                  return CarCard(
                    car: car,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CarDetailPage(car: car)),
                      );
                    },
                  );
                },
                childCount: state.cars.length,
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
