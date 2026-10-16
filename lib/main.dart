import 'package:flutter/material.dart';
import 'theme/foundhub_theme.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/report_item.dart';
import 'screens/my_reports.dart';
import 'screens/profile.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({
    super.key
  });
  @override Widget build(BuildContext context) => MaterialApp(title: 'FoundHub - Student Lost & Found',
  debugShowCheckedModeBanner: false, theme: FoundHubTheme.light,
  initialRoute: '/login', routes: {
    '/login': (_) => const LoginState(), '/register': (_) => const RegisterState(),
    '/home': (_) => const HomePage(), '/report': (_) => const ReportItemPage(),
    '/my-reports': (_) => const MyReportsPage(), '/profile': (_) => const ProfilePage(),
  }, );
}
