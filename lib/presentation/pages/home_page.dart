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
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../bloc/theme/theme_state.dart';
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

  String _sortBy = 'created_at';
  String _sortOrder = 'desc';
  
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
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    ));
  }

  void _onBrandTap(BrandEntity brand) {
    if (_selectedBrandEntity?.id == brand.id) {
      // Don't use _resetAll here to avoid resetting search terms or other things if needed, 
      // but for brand selection, we just want to deselect.
      setState(() {
        _selectedBrandEntity = null;
        _selectedSeriesEntity = null;
        _selectedModelName = null;
        _currentSeriesList = [];
        _currentModelList = [];
      });
      _applyAllFilters();
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
      _sortBy = 'created_at';
      _sortOrder = 'desc';
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
                  actionLabel: 'Sıralama',
                  onAction: _showSortOptions,
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Text('Sıralama Seçenekleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildSortItem('En Yeniler', 'created_at', 'desc'),
          _buildSortItem('Fiyat: Düşükten Yükseğe', 'price', 'asc'),
          _buildSortItem('Fiyat: Yüksekten Düşüğe', 'price', 'desc'),
          _buildSortItem('Kilometre: Düşükten Yükseğe', 'mileage', 'asc'),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSortItem(String label, String sortBy, String sortOrder) {
    final isSelected = _sortBy == sortBy && _sortOrder == sortOrder;
    return ListTile(
      title: Text(label, style: TextStyle(color: isSelected ? AppColors.primary : null, fontWeight: isSelected ? FontWeight.bold : null)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _sortBy = sortBy;
          _sortOrder = sortOrder;
        });
        Navigator.pop(context);
        _applyAllFilters();
      },
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 70,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: const Text('Kıbrıs Oto İlan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      actions: [
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: IconButton(
                icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, size: 20),
                onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.only(right: 15),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
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
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Hayalindeki özellikleri ara...', style: TextStyle(color: AppColors.textHint)),
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
        height: 110,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _buildCircleItem(image: _selectedBrandEntity!.logoUrl, label: _selectedBrandEntity!.name, isSelected: true, onTap: () => _onBrandTap(_selectedBrandEntity!)),
            const VerticalDivider(width: 30, color: Colors.white10, indent: 20, endIndent: 20),
            if (_selectedSeriesEntity == null)
              ..._currentSeriesList.map((s) => _buildCircleItem(label: s.series, onTap: () => _onSeriesTap(s)))
            else ...[
              _buildCircleItem(label: _selectedSeriesEntity!.series, isSelected: true, onTap: () => _onSeriesTap(_selectedSeriesEntity!)),
              const VerticalDivider(width: 30, color: Colors.white10, indent: 20, endIndent: 20),
              ..._currentModelList.map((m) => _buildCircleItem(label: m, isSelected: _selectedModelName == m, onTap: () => _onModelTap(m))),
            ]
          ],
        ),
      );
    }

    if (brands.isEmpty) return const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()));

    return SizedBox(
      key: const ValueKey('all_brands'),
      height: 110,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 65, height: 65,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : (image != null ? Colors.white : Theme.of(context).cardColor),
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.05), width: 2),
              boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
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
                          color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87), 
                          fontSize: label.length > 10 ? 10 : 12, 
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
          Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textHint, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : null)),
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
      backgroundColor: Theme.of(context).cardColor,
      label: Text(label, style: const TextStyle(fontSize: 12)),
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
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          TextButton(
            onPressed: onAction, 
            child: Row(
              children: [
                Text(actionLabel, style: const TextStyle(color: AppColors.primary)),
                if (actionLabel == 'Sıralama') ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.sort, color: AppColors.primary, size: 16),
                ]
              ],
            )
          ),
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
                childAspectRatio: 0.68, 
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