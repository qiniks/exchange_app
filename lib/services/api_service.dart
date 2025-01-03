import 'package:dio/dio.dart';
import '../models/currency.dart';
import '../models/transaction.dart';

class ApiService {
  final Dio _dio =
      Dio(BaseOptions(baseUrl: 'https://qiniks.pythonanywhere.com/api/'));

  Future<List<Currency>> fetchCurrencies() async {
    try {
      final response = await _dio.get('currencies/');
      return (response.data as List)
          .map((json) => Currency.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке валют: $e');
    }
  }

  Future<void> addTransaction({
    required String currency_code,
    required String type,
    required double amount,
    required double rate,
  }) async {
    try {
      await _dio.post('transactions/', data: {
        "user": 1,
        "currency": currency_code,
        "operation_type": type,
        "amount": amount,
        "rate": rate
      });
      // await _dio.post('transactions/', data:         {
      //   "id": 4,
      //   "user": 1,
      //   "currency": "JPY",
      //   "operation_type": "buy",
      //   "amount": "58.00",
      //   "rate": "39.00",
      //   "total": "2262.00",
      //   "date": "2025-01-02 22:44:05"
      // });
    } catch (e) {
      throw Exception('Ошибка при добавлении транзакции: $e');
    }
  }

  Future<List<Transaction>> fetchTransactions() async {
    try {
      final response = await _dio.get('transactions/');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка при загрузке событий: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при загрузке событий: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dio.delete('transactions/delete/$id/');
    } catch (e) {
      throw Exception('Ошибка при удалении транзакции: $e');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _dio.patch(
        'transactions/${transaction.id}/',
        data: {
          'amount': transaction.amount,
          'rate': transaction.rate,
          'total': transaction.total,
          'operation_type': transaction.operationType,
          'currency': transaction.currency,
          'user': transaction.user,
        },
      );
    } catch (e) {
      throw Exception('Ошибка при обновлении транзакции: $e');
    }
  }
}
