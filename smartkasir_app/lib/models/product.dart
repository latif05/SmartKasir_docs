import 'category.dart';

class Product {
  final int? id;
  final int? categoryId;
  final Category? category; // Relasi ke category
  final String name;
  final double? costPrice;
  final double sellPrice;
  final int stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    this.categoryId,
    this.category,
    required this.name,
    this.costPrice,
    required this.sellPrice,
    this.stock = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat Product dari JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categoryId: json['category_id'],
      category: json['category'] != null 
          ? Category.fromJson(json['category']) 
          : null,
      name: json['name'],
      costPrice: json['cost_price'] != null 
          ? (json['cost_price'] is int 
              ? json['cost_price'].toDouble() 
              : json['cost_price']) 
          : null,
      sellPrice: json['sell_price'] is int 
          ? json['sell_price'].toDouble() 
          : json['sell_price'],
      stock: json['stock'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  // Method untuk mengkonversi Product ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'stock': stock,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Method untuk membuat copy dengan field yang diubah
  Product copyWith({
    int? id,
    int? categoryId,
    Category? category,
    String? name,
    double? costPrice,
    double? sellPrice,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      name: name ?? this.name,
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method untuk format harga
  String get formattedPrice {
    final priceStr = sellPrice.toStringAsFixed(0);
    // Format dengan titik sebagai pemisah ribuan
    String formatted = '';
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += priceStr[i];
    }
    return 'Rp $formatted';
  }

  // Helper method untuk format stok
  String get stockStatus {
    if (stock <= 0) return 'Habis';
    if (stock < 10) return 'Kritis';
    return 'Tersedia';
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: ${category?.name ?? categoryId}, price: $sellPrice, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.categoryId == categoryId &&
        other.sellPrice == sellPrice;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
        name.hashCode ^ 
        categoryId.hashCode ^ 
        sellPrice.hashCode;
  }
}
