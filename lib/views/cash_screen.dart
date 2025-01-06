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
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.grey[200],
                  ),
                  dataRowColor: MaterialStateProperty.resolveWith(
                        (states) => states.contains(MaterialState.selected)
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.05),
                  ),
                  columnSpacing: 24.0,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Currency',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Total bought',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Avg bought',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Total sold',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Avg sold',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Profit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  rows: currencyData.map((currency) {
                    return DataRow(
                      cells: [
                        DataCell(Text(currency['currency'])),
                        DataCell(Text(
                            currency['total_bought'].toStringAsFixed(2))),
                        DataCell(Text(currency['avg_rate_bought']
                            .toStringAsFixed(2))),
                        DataCell(Text(
                            currency['total_sold'].toStringAsFixed(2))),
                        DataCell(Text(currency['avg_rate_sold']
                            .toStringAsFixed(2))),
                        DataCell(Text(
                          currency['profit']
                              .abs()
                              .toStringAsFixed(2),
                          style: TextStyle(
                            color: currency['profit'] >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Сом: ${totalCash.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 36),
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
