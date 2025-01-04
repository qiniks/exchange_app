import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CashScreen extends StatefulWidget {
  const CashScreen({Key? key}) : super(key: key);

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  final ApiService _apiService = ApiService();

  double totalCash = 0.0;
  double totalProfit = 0.0;
  List<dynamic> currencyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCashDeskData();
  }

  Future<void> _loadCashDeskData() async {
    try {
      final data = await _apiService.fetchCashDeskData();
      setState(() {
        totalCash = double.parse(data['total_cash']);
        totalProfit = double.parse(data['total_profit']);
        currencyData = data['currency_data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Касса')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.0,
                  columns: const [
                    DataColumn(label: Text('Валюта')),
                    DataColumn(label: Text('Куплено')),
                    DataColumn(label: Text('Сред. курс покупки')),
                    DataColumn(label: Text('Продано')),
                    DataColumn(label: Text('Сред. курс продажи')),
                    DataColumn(label: Text('Профит')),
                  ],
                  rows: currencyData.map((currency) {
                    return DataRow(cells: [
                      DataCell(Text(currency['currency'])),
                      DataCell(Text(currency['total_bought']
                          .toStringAsFixed(2))),
                      DataCell(Text(currency['avg_rate_bought']
                          .toStringAsFixed(2))),
                      DataCell(Text(currency['total_sold']
                          .toStringAsFixed(2))),
                      DataCell(Text(currency['avg_rate_sold']
                          .toStringAsFixed(2))),
                      DataCell(Text(currency['profit'].toStringAsFixed(2))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Сом: ${totalCash.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Profit: ${totalProfit.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
