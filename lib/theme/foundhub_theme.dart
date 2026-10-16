import 'package:flutter/material.dart';
class FoundHubTheme {
  static const navy = Color(0xFF0B2D52);
  static const blue = Color(0xFF123E78);
  static const gold = Color(0xFFF4CE38);
  static const canvas = Color(0xFFF4F6F9);
  static const muted = Color(0xFF64748B);
  static ThemeData get light => ThemeData(useMaterial3: true,
  scaffoldBackgroundColor: canvas, colorScheme: ColorScheme.fromSeed(seedColor: navy,
  primary: navy, secondary: gold, surface: Colors.white),
  appBarTheme: const AppBarTheme(backgroundColor: Colors.white,
  foregroundColor: navy, centerTitle: false, elevation: 0,
  titleTextStyle: TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.w800)),
  textTheme: const TextTheme(headlineSmall: TextStyle(color: navy,
  fontWeight: FontWeight.w800, fontSize: 25), titleLarge: TextStyle(color: navy,
  fontWeight: FontWeight.w800, fontSize: 19), titleMedium: TextStyle(color: navy,
  fontWeight: FontWeight.w700), bodyMedium: TextStyle(color: Color(0xFF334155))),
  cardTheme: CardThemeData(color: Colors.white, elevation: 0,
  margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
  side: const BorderSide(color: Color(0xFFE6EAF0)))), inputDecorationTheme: InputDecorationTheme(filled: true,
  fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16,
  vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(color: Color(0xFFD6DFE8))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(color: Color(0xFFD6DFE8))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(color: navy, width: 1.6))),
  filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: navy,
  foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20,
  vertical: 17), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
  outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: navy,
  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: navy,
  foregroundColor: Colors.white), );
}
class FoundHubBrand extends StatelessWidget {
  final double height;
  const FoundHubBrand({
    super.key, this.height = 54
  });
  @override Widget build(BuildContext context) => Image.asset('assets/foundhub1.png',
  height: height, fit: BoxFit.contain, errorBuilder: (_, __,
  ___) => const Text('FoundHub', style: TextStyle(fontSize: 26,
  color: FoundHubTheme.navy, fontWeight: FontWeight.w900)));
}
class WebSection extends StatelessWidget {
  final String title;
  final Widget child;
  final String?subtitle;
  const WebSection({
    super.key, required this.title, required this.child, this.subtitle
  });
  @override Widget build(BuildContext context) => Container(width: double.infinity,
  padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white,
  borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE9ECF2)),
    boxShadow: const[
    BoxShadow(color: Color(0x0B000000), blurRadius: 14, offset: Offset(0,
    4))
  ]), child: Column(crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Container(height: 5, width: 48, decoration: BoxDecoration(color: FoundHubTheme.gold,
    borderRadius: BorderRadius.circular(6))),
    const SizedBox(height: 12),
    Text(title, style: Theme.of(context).textTheme.titleLarge),
      if(subtitle!= null)...[
      const SizedBox(height: 4),
      Text(subtitle!, style: const TextStyle(color: FoundHubTheme.muted))
    ],
    const SizedBox(height: 18),
    child
  ]));
}
