import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env asset olarak yuklenir; eksikse bos kalir, Env hata firlatir.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env yoksa Env okurken kullaniciya net hata gosterir
  }
  runApp(const CRAnalyzeApp());
}

class CRAnalyzeApp extends StatelessWidget {
  const CRAnalyzeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CR Analyze',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    const seed = Color(0xFF8A2BE2); // CR mor
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      primary: const Color(0xFFB388FF),
      secondary: const Color(0xFFFFC107),
      tertiary: const Color(0xFF40C4FF),
      surface: const Color(0xFF12172A),
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0A0E1A),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A2138),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF12172A),
        foregroundColor: Color(0xFFFFC107),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFFFFC107),
          letterSpacing: 0.3,
        ),
        elevation: 2,
      ),
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ).copyWith(
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF8A2BE2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2138),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A4264), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
        ),
      ),
    );
  }
}
