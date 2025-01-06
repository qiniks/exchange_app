import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/api_service.dart';

class CurrenciesScreen extends StatefulWidget {
  const CurrenciesScreen({Key? key}) : super(key: key);

  @override
  State<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  final ApiService _apiService = ApiService();
  List<Currency> _currencies = [];

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
      });
    } catch (e) {
      print('Ошибка при загрузке валют: $e');
    }
  }

  void _deleteCurrency(int currencyId) async {
    final confirmed =
        await _showConfirmationDialog('Вы уверены, что хотите удалить валюту?');
    if (confirmed) {
      try {
        await _apiService.deleteCurrency(currencyId);
        setState(() {
          _currencies.removeWhere((currency) => currency.id == currencyId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Валюта успешно удалена')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _showAddCurrencyDialog() {
    final TextEditingController _currencyCodeController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить новую валюту'),
          content: TextField(
            controller: _currencyCodeController,
            decoration: const InputDecoration(labelText: 'Код валюты'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                _addCurrency(_currencyCodeController.text.trim());
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  /// Добавление новой валюты через API
  void _addCurrency(String currencyCode) async {
    if (currencyCode.isEmpty) return;

    try {
      await _apiService.addCurrency(currencyCode);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Валюта добавлена')),
      );
      _loadCurrencies(); // Обновить список валют
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Подтверждение'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Нет'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Да'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Валюты')),
      body: ListView.separated(
        itemCount: _currencies.length,
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          height: 1,
          color: Colors.white,
        ),
        itemBuilder: (context, index) {
          final currency = _currencies[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              title: Text(
                currency.code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCurrency(currency.id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCurrencyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
