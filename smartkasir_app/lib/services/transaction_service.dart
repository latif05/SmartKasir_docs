import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class TransactionService {
  static const String baseUrl = 'http://localhost:3000';
  
  // Headers untuk request
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET /transactions - Mendapatkan semua transaksi
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  // GET /transactions/:id - Mendapatkan transaksi berdasarkan ID
  Future<Transaction> getTransactionById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Transaction.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Transaction not found');
      } else {
        throw Exception('Failed to load transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transaction: $e');
    }
  }

  // POST /transactions - Membuat transaksi baru
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: _headers,
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        return Transaction.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }
}
