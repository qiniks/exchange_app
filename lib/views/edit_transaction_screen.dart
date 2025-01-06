import 'package:flutter/material.dart';
import '../models/transaction.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController amountController;
  late TextEditingController rateController;

  @override
  void initState() {
    super.initState();
    amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    rateController =
        TextEditingController(text: widget.transaction.rate.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать событие')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Количество'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: rateController,
              decoration: const InputDecoration(labelText: 'Курс'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedTransaction = Transaction(
                  id: widget.transaction.id,
                  user: widget.transaction.user,
                  currency: widget.transaction.currency,
                  operationType: widget.transaction.operationType,
                  amount: double.parse(amountController.text),
                  rate: double.parse(rateController.text),
                  total: double.parse(amountController.text) *
                      double.parse(rateController.text),
                  date: widget.transaction.date,
                );

                Navigator.pop(context, updatedTransaction);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
