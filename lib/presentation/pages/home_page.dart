import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';
import '../widgets/home/car_card.dart';
import 'car_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    _checkAndFetch();
  }

  void _checkAndFetch() {
    final carBloc = context.read<CarBloc>();
    if (carBloc.state is CarInitial || carBloc.state is CarError) {
      _fetchCars();
    }
  }

  void _fetchCars({String? brand}) {
    if (!mounted) return;
    setState(() => _selectedBrand = brand);
    context.read<CarBloc>().add(GetCarsEvent(
      brand: brand,
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
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: 'Popüler Markalar', 
                  onSeeAll: () => _fetchCars(brand: null)
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
          onTap: () {},
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
    final brands = [
      {'name': 'BMW', 'icon': Icons.directions_car},
      {'name': 'Mercedes', 'icon': Icons.stars},
      {'name': 'Audi', 'icon': Icons.incomplete_circle},
      {'name': 'Toyota', 'icon': Icons.airport_shuttle},
      {'name': 'Honda', 'icon': Icons.local_taxi},
      {'name': 'Ford', 'icon': Icons.commute},
    ];
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final brand = brands[index];
          final isSelected = _selectedBrand == brand['name'];
          return Column(
            children: [
              InkWell(
                onTap: () => _fetchCars(brand: brand['name'] as String),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface, 
                    shape: BoxShape.circle, 
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
                  ),
                  child: Icon(brand['icon'] as IconData, color: isSelected ? Colors.black : AppColors.textPrimary, size: 30),
                ),
              ),
              const SizedBox(height: 8),
              Text(brand['name'] as String, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textHint, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCarGrid() {
    return BlocBuilder<CarBloc, CarState>(
      // NOKTA ATIŞI: Sadece bu durumlar oluştuğunda UI'ı baştan çiz. 
      // Detay yüklendiğinde veya favori değiştiğinde gridi bozma.
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
                      ); // .then(..) kısmını kaldırdım, çünkü CarBloc artık listeyi otomatik güncelliyor.
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