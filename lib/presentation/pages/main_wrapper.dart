import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart' as di;
import '../bloc/car/car_bloc.dart';
import '../bloc/user/user_bloc.dart';
import 'home_page.dart';
import 'favorites_page.dart';
import 'create_listing_page.dart';
import 'profile_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(create: (_) => di.sl<UserBloc>()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: const [
                HomePage(),
                FavoritesPage(),
                _CreateListingPlaceholder(),
                ProfilePage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 2) {
                  // Create listing - navigate to page
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: BlocProvider.of<CarBloc>(context),
                        child: const CreateListingPage(),
                      ),
                    ),
                  );
                  return;
                }
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favoriler',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  activeIcon: Icon(Icons.add_circle),
                  label: 'İlan Ekle',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Placeholder widget for the create listing tab in IndexedStack.
/// The actual page is opened via navigation when the tab is tapped.
class _CreateListingPlaceholder extends StatelessWidget {
  const _CreateListingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
