import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/api_service.dart';

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
          _selectedCurrency = _currencies.first;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Основной экран')),
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
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Buy'),
                    style: ElevatedButton.styleFrom(
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
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Sell'),
                    style: ElevatedButton.styleFrom(
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
              decoration: const InputDecoration(labelText: 'Выберите валюту'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Количество'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _amount = double.tryParse(value) ?? 0.0;
                _calculateTotal();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Курс'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _rate = double.tryParse(value) ?? 0.0;
                _calculateTotal();
              },
            ),
            const SizedBox(height: 16),
            Text('Итог: $_total'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text('Add'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Открыть экран событий
                Navigator.pushNamed(context, '/events');
              },
              child: const Text('События'),
            ),
          ],
        ),
      ),
    );
  }
}
