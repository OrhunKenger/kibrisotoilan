import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../widgets/car_list_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import 'car_detail_page.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<UserBloc>().add(const GetMyListingsEvent(page: 1, limit: 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlanlarım')),
      body: BlocBuilder<UserBloc, UserState>(
        buildWhen: (_, current) =>
            current is MyListingsLoading ||
            current is MyListingsLoaded ||
            current is MyListingsError,
        builder: (context, state) {
          if (state is MyListingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MyListingsLoaded) {
            if (state.listings.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.list_alt,
                title: 'Henüz ilanınız yok',
                subtitle: 'Yeni bir ilan ekleyerek baslayabilirsiniz',
              );
            }
            return RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: state.listings.length,
                itemBuilder: (context, index) {
                  final car = state.listings[index];
                  return CarListCard(
                    car: car,
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
                  );
                },
              ),
            );
          } else if (state is MyListingsError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: _load,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
