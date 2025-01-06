import 'package:flutter/material.dart';
import 'views/cash_screen.dart';
import 'views/currencies_screen.dart';
import 'views/events_screen.dart';
import 'views/login_screen.dart';
import 'views/main_screen.dart';
import 'views/report_screen.dart';
import 'views/users_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Exchange',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, // Включить фон
          fillColor: Colors.grey[200], // Цвет фона
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey, // Цвет текста метки
          ),
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Colors.grey, // Цвет подсказки
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey), // Граница в неактивном состоянии
            borderRadius: BorderRadius.circular(10.0), // Закругленные края
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2.0), // Граница в активном состоянии
            borderRadius: BorderRadius.circular(10.0), // Закругленные края
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red), // Граница при ошибке
            borderRadius: BorderRadius.circular(10.0), // Закругленные края
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2.0), // Граница при активной ошибке
            borderRadius: BorderRadius.circular(10.0), // Закругленные края
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        '/events': (context) => const EventsScreen(),
        '/currencies': (context) => const CurrenciesScreen(),
        '/users': (context) => const UsersScreen(),
        '/cash': (context) => const CashScreen(),
        '/report': (context) => const ReportScreen(),
      },
    );
  }
}
