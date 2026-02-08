import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;
  static const String _themeKey = 'theme_mode';

  ThemeBloc({required this.sharedPreferences}) : super(const ThemeState(ThemeMode.dark)) {
    on<LoadThemeEvent>((event, emit) {
      final isDark = sharedPreferences.getBool(_themeKey) ?? true;
      emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
    });

    on<ToggleThemeEvent>((event, emit) async {
      final isDark = state.themeMode == ThemeMode.dark;
      await sharedPreferences.setBool(_themeKey, !isDark);
      emit(ThemeState(!isDark ? ThemeMode.dark : ThemeMode.light));
    });
  }
}
