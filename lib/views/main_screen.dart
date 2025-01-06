import 'package:exhange_app/views/report_screen.dart';
import 'package:exhange_app/views/users_screen.dart';
import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/api_service.dart';
import 'cash_screen.dart';
import 'currencies_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();

  List<Currency> _currencies = [];
  Currency? _selectedCurrency;
  bool _isBuying = true; // Покупка или продажа
  double _amount = 0.0;
  double _rate = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  void _loadCurrencies() async {
    try {
      final currencies = await _apiService.fetchCurrencies();
      setState(() {
        _currencies = currencies;
        if (_currencies.isNotEmpty) {
          _selectedCurrency = null;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _calculateTotal() {
    setState(() {
      _total = _amount * _rate;
    });
  }

  void _addTransaction() async {
    if (_selectedCurrency != null && _amount > 0 && _rate > 0) {
      try {
        await _apiService.addTransaction(
          currency_code: _selectedCurrency!.code,
          type: _isBuying ? 'buy' : 'sell',
          amount: _amount,
          rate: _rate,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Операция добавлена')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _showClearDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтвердите действие'),
          content: const Text('Вы уверены, что хотите очистить базу данных?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Нет'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
                _clearDatabase(); // Очистка базы данных
              },
              child: const Text('Да'),
            ),
          ],
        );
      },
    );
  }

  void _clearDatabase() async {
    try {
      await _apiService.clearDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('База данных успешно очищена')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при очистке базы данных: $e')),
      );
    }
  }

  Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Анимация начинается справа
        const end = Offset.zero; // Конечная позиция
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main screen')),
      drawer: Drawer(
        width: 250,
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.currency_exchange),
                title: const Text('Currencies'),
                onTap: () {
                  Navigator.of(context)
                      .push(createRoute(const CurrenciesScreen()))
                      .then((_) {
                    _loadCurrencies(); // Обновляем данные после возврата с экрана
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Users'),
                onTap: () {
                  Navigator.of(context).push(createRoute(const UsersScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.wallet_outlined),
                title: const Text('Cash'),
                onTap: () {
                  Navigator.of(context).push(createRoute(const CashScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.newspaper),
                title: const Text('Report'),
                onTap: () {
                  Navigator.of(context).push(createRoute(const ReportScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore_from_trash),
                title: const Text('Clear'),
                onTap: () {
                  _showClearDatabaseDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isBuying = true);
                    },
                    icon: const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                    ),
                    label: const Text('Buy'),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      foregroundColor: _isBuying ? Colors.white : Colors.white,
                      // Цвет текста
                      backgroundColor: _isBuying ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isBuying = false);
                    },
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    label: const Text('Sell'),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      foregroundColor: _isBuying ? Colors.white : Colors.white,
                      // Цвет текста
                      backgroundColor: !_isBuying ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Currency>(
              value: _selectedCurrency,
              items: _currencies
                  .map((currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency.code),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCurrency = value);
              },
              decoration: const InputDecoration(labelText: 'Select currency'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _amount = double.tryParse(value) ?? 0.0;
                _calculateTotal();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Change rate'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _rate = double.tryParse(value) ?? 0.0;
                _calculateTotal();
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Total: $_total',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, // Максимальная ширина
              child: OutlinedButton(
                onPressed: _addTransaction,
                child: const Text('Add'),
              ),
            ),
            SizedBox(
              width: double.infinity, // Максимальная ширина
              child: OutlinedButton(
                onPressed: () {
                  // Открыть экран событий
                  Navigator.pushNamed(context, '/events');
                },
                child: const Text('Events'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
