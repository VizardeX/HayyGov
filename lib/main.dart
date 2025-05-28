import 'package:continuehayygov/screens/auth_page_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './providers/auth_provider.dart';
import './screens/login_screen.dart';
import './screens/CIT/citizen_home_screen.dart';
import './screens/AD/advertiser_dashboard_screen.dart';
import 'firebase_options.dart';
import './screens/GOV/government_main_screen.dart';
import 'services/notification_service.dart'; // ✅ NEW

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // ✅ NEW

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
  } catch (e) {}

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init(); // ✅ NEW

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'HayyGov',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          scaffoldBackgroundColor: const Color(0xFFF5E9DA), // sand-like background
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown).copyWith(
            secondary: const Color(0xFFD2B48C), // tan/sand accent
            primary: const Color(0xFFC2B280), // sand primary
            onPrimary: Colors.black, // text/icons on sand
            onSecondary: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
            background: const Color(0xFFF5E9DA),
            onBackground: Colors.black,
            error: Colors.red,
            onError: Colors.white,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE5D3B3), // lighter sand for app bar
            foregroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            elevation: 1,
          ),
          cardColor: const Color(0xFFF5E9DA),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            hintStyle: TextStyle(color: const Color(0xFF8E8E8E)),
          ),
          dividerColor: Color(0xFFD2B48C),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStatePropertyAll(Color(0xFFD2B48C)),
            trackColor: MaterialStatePropertyAll(Color(0xFFC2B280)),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStatePropertyAll(Color(0xFFD2B48C)),
            checkColor: MaterialStatePropertyAll(Colors.black),
          ),
          radioTheme: RadioThemeData(
            fillColor: MaterialStatePropertyAll(Color(0xFFD2B48C)),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.brown,
            selectionColor: Color(0xFFD2B48C),
            selectionHandleColor: Colors.brown,
          ),
        ),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // ✅ NEW
        routes: {
          '/': (context) => const AuthPageView(),
          '/citizenHome': (context) => const CitizenHomeScreen(),
          '/govHome': (context) => const GovernmentMainScreen(),
          '/advertiserDashboard': (context) => const AdvertiserDashboardScreen(),
        },
      ),
    );
  }
}
