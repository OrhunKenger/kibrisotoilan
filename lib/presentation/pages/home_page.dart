import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/brand_entity.dart';
import '../../core/utils/ui_helpers.dart';
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
  SeriesModels? _selectedSeriesEntity;
  String? _selectedModelName;
  
  List<SeriesModels> _currentSeriesList = [];
  List<String> _currentModelList = [];
  
  // Keep internal state but remove the UI toggle as requested
  final DisplayCurrency _displayCurrency = DisplayCurrency.gbp;

  @override
  void initState() {
    super.initState();
    _initialFetch();
  }

  void _initialFetch() {
    context.read<CarBloc>().add(const GetAllBrandsEvent());
    _applyAllFilters();
  }

  void _applyAllFilters() {
    if (!mounted) return;
    
    String? modelSearchTerm;
    if (_selectedModelName != null) {
      modelSearchTerm = "${_selectedSeriesEntity?.series} $_selectedModelName";
    } else if (_selectedSeriesEntity != null) {
      modelSearchTerm = _selectedSeriesEntity!.series;
    }

    context.read<CarBloc>().add(GetCarsEvent(
      brand: _selectedBrandEntity?.name,
      model: modelSearchTerm,
      page: 1,
      limit: 20,
      sortBy: 'created_at',
      sortOrder: 'desc',
    ));
  }

  void _onBrandTap(BrandEntity brand) {
    if (_selectedBrandEntity?.id == brand.id) {
      _resetAll();
    } else {
      setState(() {
        _selectedBrandEntity = brand;
        _selectedSeriesEntity = null;
        _selectedModelName = null;
        _currentSeriesList = [];
        _currentModelList = [];
      });
      context.read<CarBloc>().add(GetSeriesAndModelsEvent(brandId: brand.id));
      _applyAllFilters();
    }
  }

  void _onSeriesTap(SeriesModels series) {
    if (_selectedSeriesEntity?.id == series.id) {
      setState(() {
        _selectedSeriesEntity = null;
        _selectedModelName = null;
        _currentModelList = [];
      });
    } else {
      setState(() {
        _selectedSeriesEntity = series;
        _currentModelList = series.models;
        _selectedModelName = null;
      });
    }
    _applyAllFilters();
  }

  void _onModelTap(String modelName) {
    setState(() {
      if (_selectedModelName == modelName) {
        _selectedModelName = null;
      } else {
        _selectedModelName = modelName;
      }
    });
    _applyAllFilters();
  }

  void _resetAll() {
    setState(() {
      _selectedBrandEntity = null;
      _selectedSeriesEntity = null;
      _selectedModelName = null;
      _currentSeriesList = [];
      _currentModelList = [];
    });
    _applyAllFilters();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) _applyAllFilters();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: () async {
            _applyAllFilters();
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildQuickTools()),
              
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: 'Popüler Markalar', 
                  actionLabel: 'Sıfırla',
                  onAction: _resetAll,
                )
              ),
              SliverToBoxAdapter(child: _buildBrandSelectionArea()),

              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: _selectedBrandEntity == null ? 'Son İlanlar' : '${_selectedBrandEntity!.name} İlanları', 
                  actionLabel: 'Tümü',
                  onAction: () {},
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

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 70,
      backgroundColor: AppColors.background,
      elevation: 0,
      title: const Text('Kıbrıs Oto İlan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 15),
          decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FilterBottomSheet(
            initialBrand: _selectedBrandEntity?.name,
            initialModel: _selectedModelName ?? _selectedSeriesEntity?.series,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Detaylı Ara...', style: TextStyle(color: AppColors.textHint)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSelectionArea() {
    return BlocListener<CarBloc, CarState>(
      listener: (context, state) {
        if (state is SeriesAndModelsLoaded) {
          setState(() => _currentSeriesList = state.seriesModels);
        }
      },
      child: BlocBuilder<CarBloc, CarState>(
        buildWhen: (prev, curr) => curr is AllBrandsLoaded,
        builder: (context, state) {
          List<BrandEntity> brands = [];
          if (state is AllBrandsLoaded) brands = state.brands;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildSelectionContent(brands),
          );
        },
      ),
    );
  }

  Widget _buildSelectionContent(List<BrandEntity> brands) {
    if (_selectedBrandEntity != null) {
      return SizedBox(
        key: ValueKey('sel_${_selectedBrandEntity!.id}_${_selectedSeriesEntity?.id}_$_selectedModelName'),
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _buildCircleItem(image: _selectedBrandEntity!.logoUrl, label: _selectedBrandEntity!.name, isSelected: true, onTap: _resetAll),
            const VerticalDivider(width: 30, color: Colors.white10, indent: 20, endIndent: 20),
            if (_selectedSeriesEntity == null)
              ..._currentSeriesList.map((s) => _buildCircleItem(label: s.series, onTap: () => _onSeriesTap(s)))
            else ...[
              _buildCircleItem(label: _selectedSeriesEntity!.series, isSelected: true, onTap: () => setState(() => _selectedSeriesEntity = null)),
              const VerticalDivider(width: 30, color: Colors.white10, indent: 20, endIndent: 20),
              ..._currentModelList.map((m) => _buildCircleItem(label: m, isSelected: _selectedModelName == m, onTap: () => _onModelTap(m))),
            ]
          ],
        ),
      );
    }

    if (brands.isEmpty) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));

    return SizedBox(
      key: const ValueKey('all_brands'),
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) => _buildCircleItem(image: brands[index].logoUrl, label: brands[index].name, onTap: () => _onBrandTap(brands[index])),
      ),
    );
  }

  Widget _buildCircleItem({String? image, required String label, bool isSelected = false, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60, height: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : (image != null ? Colors.white : AppColors.surface),
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppColors.primary : Colors.white10, width: 2),
            ),
            child: image != null
                ? CachedNetworkImage(imageUrl: image, fit: BoxFit.contain, errorWidget: (c,u,e) => const Icon(Icons.directions_car))
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        label, 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white, 
                          fontSize: label.length > 10 ? 8 : 10, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ),
          ),
        ),
        // Sadece markalar (resimli olanlar) için alt yazı göster
        if (image != null) ...[
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textHint, fontSize: 11)),
        ],
      ],
    );
  }

  Widget _buildQuickTools() {
    return SizedBox(
      height: 50,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _buildToolBtn('Devir Hesapla', Icons.calculate_outlined, () => showModalBottomSheet(context: context, builder: (context) => const DevirHesaplaOptionsSheet())),
          const SizedBox(width: 12),
          _buildToolBtn('Hasar Sorgula', Icons.history_edu_outlined, () {}),
        ],
      ),
    );
  }

  Widget _buildToolBtn(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: AppColors.surface,
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      avatar: Icon(icon, color: AppColors.primary, size: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onAction, required String actionLabel}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis)),
          TextButton(onPressed: onAction, child: Text(actionLabel, style: const TextStyle(color: AppColors.primary))),
        ],
      ),
    );
  }

  Widget _buildCarGrid() {
    return BlocBuilder<CarBloc, CarState>(
      buildWhen: (prev, curr) => curr is CarsLoaded || curr is CarLoading || curr is CarError,
      builder: (context, state) {
        if (state is CarLoading) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        if (state is CarError) return SliverFillRemaining(child: Center(child: Text(state.message)));
        if (state is CarsLoaded) {
          if (state.cars.isEmpty) return const SliverFillRemaining(child: Center(child: Text('İlan bulunamadı.')));
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 0.7, 
                crossAxisSpacing: 15, 
                mainAxisSpacing: 15
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => CarCard(
                  car: state.cars[index],
                  displayCurrency: _displayCurrency,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CarDetailPage(car: state.cars[index]))),
                ),
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