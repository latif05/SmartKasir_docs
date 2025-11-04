import 'transaction_item.dart';

class Transaction {
  final int? id;
  final DateTime date;
  final double total;
  final double discount;
  final double finalAmount;
  final String? paymentMethod;
  final String? status;
  final DateTime? createdAt;
  final List<TransactionItem>? items; // List items dalam transaksi

  Transaction({
    this.id,
    required this.date,
    required this.total,
    this.discount = 0,
    required this.finalAmount,
    this.paymentMethod,
    this.status,
    this.createdAt,
    this.items,
  });

  // Factory constructor untuk membuat Transaction dari JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      total: json['total'] is int 
          ? json['total'].toDouble() 
          : json['total'],
      discount: json['discount'] != null 
          ? (json['discount'] is int 
              ? json['discount'].toDouble() 
              : json['discount']) 
          : 0,
      finalAmount: json['final_amount'] is int 
          ? json['final_amount'].toDouble() 
          : json['final_amount'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      items: json['items'] != null 
          ? (json['items'] as List)
              .map((item) => TransactionItem.fromJson(item))
              .toList()
          : null,
    );
  }

  // Method untuk mengkonversi Transaction ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'total': total,
      'discount': discount,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  // Method untuk membuat copy dengan field yang diubah
  Transaction copyWith({
    int? id,
    DateTime? date,
    double? total,
    double? discount,
    double? finalAmount,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    List<TransactionItem>? items,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  // Helper method untuk format waktu transaksi
  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper method untuk format tanggal
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method untuk format total
  String get formattedTotal {
    final priceStr = finalAmount.toStringAsFixed(0);
    String formatted = '';
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += priceStr[i];
    }
    return 'Rp $formatted';
  }

  // Helper method untuk mendapatkan summary produk
  String get productsSummary {
    if (items == null || items!.isEmpty) return '-';
    
    if (items!.length == 1) {
      final item = items!.first;
      return '${item.product?.name ?? 'Unknown'} x${item.qty}';
    }
    
    // Jika lebih dari 1 item, tampilkan item pertama + jumlah item lainnya
    final firstItem = items!.first;
    final otherItemsCount = items!.length - 1;
    return '${firstItem.product?.name ?? 'Unknown'} x${firstItem.qty} + $otherItemsCount lainnya';
  }

  @override
  String toString() {
    return 'Transaction(id: $id, date: $date, total: $total, finalAmount: $finalAmount)';
  }
}
