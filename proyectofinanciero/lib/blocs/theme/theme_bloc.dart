import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme_mode';

  ThemeBloc() : super(const ThemeState(ThemeMode.light)) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      ThemeMode themeMode;
      switch (savedTheme) {
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'system':
          themeMode = ThemeMode.system;
          break;
        case 'light':
        default:
          themeMode = ThemeMode.light;
          break;
      }

      emit(ThemeState(themeMode));
    } catch (e) {
      emit(const ThemeState(ThemeMode.light));
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final newTheme = state.themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, newTheme.name);

      emit(ThemeState(newTheme));
    } catch (e) {
      // Si hay error, mantener el tema actual
    }
  }

  Future<void> _onSetTheme(SetTheme event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, event.themeMode.name);

      emit(ThemeState(event.themeMode));
    } catch (e) {
      // Si hay error, mantener el tema actual
    }
  }
}
