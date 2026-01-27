import 'package:flutter/material.dart';

const primaryPurple = Color(0xFF7C3AED);
const primaryPurpleDark = Color(0xFF6D28D9);
const primaryPurpleLight = Color(0xFF8B5CF6);

const backgroundColor = Color(0xFFF8FAFC);
const surfaceColor = Color(0xFFFFFFFF);
const surfaceMuted = Color(0xFFF5F0FF);

const textPrimary = Color(0xFF0F172A);
const textSecondary = Color(0xFF475569);
const textMuted = Color(0xFF94A3B8);

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: backgroundColor,
  primaryColor: primaryPurple,
  appBarTheme: const AppBarTheme(
    backgroundColor: surfaceColor,
    elevation: 0,
    foregroundColor: textPrimary,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryPurple,
    primary: primaryPurple,
  ),
);
