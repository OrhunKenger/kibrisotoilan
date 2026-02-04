import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/car/car_event.dart';
import '../bloc/car/car_state.dart';
import '../widgets/car_list_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import 'car_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final ScrollController _scrollController = ScrollController();
  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFavorites();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreFavorites();
    }
  }

  void _loadMoreFavorites() {
    final state = context.read<CarBloc>().state;
    if (state is FavoritesLoaded && !state.hasReachedMax) {
      context.read<CarBloc>().add(
        GetMyFavoritesEvent(page: state.currentPage + 1, limit: _limit),
      );
    }
  }

  void _loadFavorites() {
    context.read<CarBloc>().add(const GetMyFavoritesEvent(page: 1, limit: _limit));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: BlocConsumer<CarBloc, CarState>(
        listener: (context, state) {
          if (state is FavoriteToggled && !state.isFavorite) {
            // Reload after removing a favorite
            _loadFavorites();
          }
        },
        buildWhen: (_, current) =>
            current is FavoritesLoading ||
            current is FavoritesLoaded ||
            current is FavoriteError,
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.favorite_border,
                title: 'Henüz favori yok',
                subtitle: 'Beğendiğiniz ilanları favorilerinize ekleyin',
              );
            }
            return RefreshIndicator(
              onRefresh: () async => _loadFavorites(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: state.favorites.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.favorites.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final car = state.favorites[index];
                  return CarListCard(
                    car: car,
                    isFavorite: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<CarBloc>(),
                            child: CarDetailPage(carId: car.id!),
                          ),
                        ),
                      );
                    },
                    onFavorite: () {
                      context.read<CarBloc>().add(RemoveFavoriteEvent(carId: car.id!));
                    },
                  );
                },
              ),
            );
          } else if (state is FavoriteError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: _loadFavorites,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
