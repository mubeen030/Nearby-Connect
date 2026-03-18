import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final isDarkModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(themeModeProvider);
  if (mode == ThemeMode.system) {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }
  return mode == ThemeMode.dark;
});
