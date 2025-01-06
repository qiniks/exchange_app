import 'package:dio/dio.dart';
import '../models/currency.dart';
import '../models/transaction.dart';

class ApiService {
  final Dio _dio =
      Dio(BaseOptions(baseUrl: 'https://qiniks.pythonanywhere.com/api/'));

  Future<bool> logIn(String username, String password) async {
    try {
      final response = await _dio.post(
        'authenticate/',
        data: {
          "username": username,
          "password": password,
        },
      );

      // Проверка успешного ответа
      if (response.statusCode == 200) {
        return true; // Пользователь успешно прошел проверку
      } else if (response.statusCode == 401) {
        print("Неверный пароль или username");
      }
      return false;
    } catch (e) {
      // Логирование ошибки для диагностики
      // print('Ошибка при аутентификации: $e');
      rethrow; // Пробрасываем ошибку дальше для обработки
    }
  }

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

  Future<void> addCurrency(String currencyCode) async {
    try {
      await _dio.post('currencies/', data: {
        'code': currencyCode,
      });
    } catch (e) {
      throw Exception('Ошибка при добавлении валюты: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final response = await _dio.get('users/');
      // Ответ уже является списком объектов, а не объектом с ключом 'data'
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Ошибка при загрузке пользователей: $e');
    }
  }

  Future<void> addUser(String username, String password) async {
    try {
      await _dio.post('register/', data: {
        'username': username,
        'password': password,
      });
    } catch (e) {
      throw Exception('Ошибка при добавлении пользователя: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCashDeskData() async {
    try {
      final response = await _dio.get('cash-register/');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Ошибка загрузки данных: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  Future<void> clearDatabase() async {
    try {
      await _dio.post('clear-database/');
    } catch (e) {
      throw Exception('Ошибка при очистке базы данных: $e');
    }
  }

  Future<void> deleteCurrency(int currencyId) async {
    try {
      await _dio.delete('currencies/delete/$currencyId/');
    } catch (e) {
      throw Exception('Ошибка при очистке базы данных: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete('users/delete/$userId/');
    } catch (e) {
      throw Exception('Ошибка при очистке базы данных: $e');
    }
  }
}
