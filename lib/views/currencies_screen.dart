import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/currency.dart';

class CurrenciesScreen extends StatefulWidget {
  const CurrenciesScreen({Key? key}) : super(key: key);

  @override
  State<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  final ApiService _apiService = ApiService();
  List<Currency> _currencies = [];
  final TextEditingController _currencyCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final currencies = await _apiService.fetchCurrencies();
      setState(() {
        _currencies = currencies;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке валют: $e')),
      );
    }
  }

  Future<void> _addCurrency() async {
    final newCurrencyCode = _currencyCodeController.text.trim();
    if (newCurrencyCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите код валюты')),
      );
      return;
    }

    try {
      await _apiService.addCurrency(newCurrencyCode);
      _currencyCodeController.clear();
      await _loadCurrencies(); // Обновить список
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Валюта добавлена')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении валюты: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Валюты')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final currency = _currencies[index];
                  return ListTile(
                    title: Text(currency.code),
                  );
                },
              ),
            ),
            TextField(
              controller: _currencyCodeController,
              decoration: const InputDecoration(
                labelText: 'Добавить новую валюту',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addCurrency,
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
