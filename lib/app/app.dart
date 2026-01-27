import 'package:flutter/material.dart';
import 'theme.dart';
import '../navigation/main_scaffold.dart';

class CovoiCamApp extends StatelessWidget {
  const CovoiCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CovoiCam",
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const MainScaffold(),
    );
  }
}
