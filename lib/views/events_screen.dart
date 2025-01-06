import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/currency.dart';
import '../services/api_service.dart';
import 'edit_transaction_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<Transaction>> transactions;
  late Future<List<Currency>> currencies;
  String? selectedCurrency = 'All';
  String? selectedOperationType = 'All';

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    transactions = apiService.fetchTransactions();
    currencies = apiService.fetchCurrencies();
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await apiService.deleteTransaction(id);
      setState(() {
        transactions = apiService.fetchTransactions();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении события: $e')),
      );
    }
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final updatedTransaction = await Navigator.push<Transaction?>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );

    if (updatedTransaction != null) {
      try {
        await apiService.updateTransaction(updatedTransaction);
        setState(() {
          transactions = apiService.fetchTransactions();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при обновлении события: $e')),
        );
      }
    }
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    return transactions.where((transaction) {
      final matchesCurrency =
          selectedCurrency == 'All' || transaction.currency == selectedCurrency;
      final matchesOperationType = selectedOperationType == 'All' ||
          transaction.operationType == selectedOperationType;
      return matchesCurrency && matchesOperationType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('События')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        // Добавляем отступы для всего экрана
        child: Column(
          children: [
            FutureBuilder<List<Currency>>(
              future: currencies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Ошибка загрузки валют: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Нет доступных валют');
                } else {
                  final allCurrencies = [
                    'All',
                    ...snapshot.data!.map((currency) => currency.code)
                  ];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Первый Dropdown
                      SizedBox(
                        width: 100, // Фиксированная ширина для Dropdown
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Currency', // Текст заголовка
                          ),
                          value: selectedCurrency,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              selectedCurrency = value;
                            });
                          },
                          items: allCurrencies
                              .map((currency) => DropdownMenuItem(
                                    value: currency,
                                    child: Text(currency),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Второй Dropdown
                      SizedBox(
                        width: 100, // Фиксированная ширина для Dropdown
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Type', // Текст заголовка
                          ),
                          value: selectedOperationType,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              selectedOperationType = value;
                            });
                          },
                          items: ['All', 'buy', 'sell']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16), // Добавим вертикальный отступ
            Expanded(
              child: FutureBuilder<List<Transaction>>(
                future: transactions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Нет данных'));
                  } else {
                    final filteredTransactions =
                        _filterTransactions(snapshot.data!);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[200]),
                        columnSpacing: 20.0,
                        columns: const [
                          DataColumn(
                              label: Text('Дата',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Валюта',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Тип',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Кол-во',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Курс',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Итог',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Действия',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredTransactions.map((transaction) {
                          final rowColor = transaction.operationType == 'buy'
                              ? Colors.red[100]
                              : transaction.operationType == 'sell'
                                  ? Colors.green[100]
                                  : null;

                          return DataRow(
                            color: MaterialStateProperty.resolveWith(
                                (states) => rowColor),
                            cells: [
                              DataCell(Text(transaction.date)),
                              DataCell(Text(transaction.currency)),
                              DataCell(Text(transaction.operationType)),
                              DataCell(Text(transaction.amount.toString())),
                              DataCell(Text(transaction.rate.toString())),
                              DataCell(Text(transaction.total.toString())),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _editTransaction(transaction),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteTransaction(transaction.id),
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
