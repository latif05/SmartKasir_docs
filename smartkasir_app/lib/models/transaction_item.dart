import 'product.dart';

class TransactionItem {
  final int? id;
  final int? transactionId;
  final int? productId;
  final Product? product; // Relasi ke product
  final int qty;
  final double sellPrice;
  final double subtotal;

  TransactionItem({
    this.id,
    this.transactionId,
    this.productId,
    this.product,
    required this.qty,
    required this.sellPrice,
    required this.subtotal,
  });

  // Factory constructor untuk membuat TransactionItem dari JSON
  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      transactionId: json['transaction_id'],
      productId: json['product_id'],
      product: json['product'] != null 
          ? Product.fromJson(json['product']) 
          : null,
      qty: json['qty'] ?? 0,
      sellPrice: json['sell_price'] is int 
          ? json['sell_price'].toDouble() 
          : json['sell_price'],
      subtotal: json['subtotal'] is int 
          ? json['subtotal'].toDouble() 
          : json['subtotal'],
    );
  }

  // Method untuk mengkonversi TransactionItem ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'qty': qty,
      'sell_price': sellPrice,
      'subtotal': subtotal,
    };
  }

  // Method untuk membuat copy dengan field yang diubah
  TransactionItem copyWith({
    int? id,
    int? transactionId,
    int? productId,
    Product? product,
    int? qty,
    double? sellPrice,
    double? subtotal,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      qty: qty ?? this.qty,
      sellPrice: sellPrice ?? this.sellPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  // Helper method untuk format subtotal
  String get formattedSubtotal {
    final priceStr = subtotal.toStringAsFixed(0);
    String formatted = '';
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += priceStr[i];
    }
    return 'Rp $formatted';
  }

  @override
  String toString() {
    return 'TransactionItem(id: $id, product: ${product?.name ?? productId}, qty: $qty, subtotal: $subtotal)';
  }
}
