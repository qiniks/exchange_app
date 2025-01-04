import 'package:flutter/material.dart';
import 'views/cash_screen.dart';
import 'views/currencies_screen.dart';
import 'views/events_screen.dart';
import 'views/login_screen.dart';
import 'views/main_screen.dart';
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
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        '/events': (context) => const EventsScreen(),
        '/currencies': (context) => const CurrenciesScreen(),
        '/users': (context) => const UsersScreen(),
        '/cash': (context) => const CashScreen(),

      },
    );
  }
}
