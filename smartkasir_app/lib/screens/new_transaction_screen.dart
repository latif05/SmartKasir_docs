import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../services/product_service.dart';
import '../services/transaction_service.dart';
import '../widgets/responsive_sidebar_scaffold.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();

  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();

  List<Product> _products = [];
  List<TransactionItem> _cartItems = [];
  bool _isLoadingProducts = true;
  bool _isProcessing = false;
  bool _isDiscountPercentage = false;
  String? _errorMessage;

  double get _subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double get _discount {
    final rawValue = _discountController.text.replaceAll(',', '.').trim();
    final parsed = double.tryParse(rawValue) ?? 0;
    if (_subtotal <= 0) return 0;

    if (_isDiscountPercentage) {
      final percent = parsed.clamp(0, 100);
      return (_subtotal * percent / 100).clamp(0, _subtotal);
    }
    return parsed.clamp(0, _subtotal);
  }

  double get _total => (_subtotal - _discount).clamp(0, double.infinity);

  double get _cash {
    final rawValue = _cashController.text.replaceAll(',', '.').trim();
    return double.tryParse(rawValue) ?? 0;
  }

  double get _change => _cash - _total;

  @override
  void initState() {
    super.initState();
    _productSearchController.addListener(() => setState(() {}));
    _loadProducts();
  }

  @override
  void dispose() {
    _discountController.dispose();
    _cashController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoadingProducts = true;
        _errorMessage = null;
      });

      final products = await _productService.getProducts();
      setState(() {
        _products = products
            .where((product) => product.stock > 0)
            .toList(); // only stock
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingProducts = false;
      });
    }
  }

  void _startNewTransaction() {
    setState(() {
      _cartItems.clear();
      _discountController.clear();
      _cashController.clear();
      _isDiscountPercentage = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi baru dimulai')),
    );
  }

  void _addToCart(Product product) {
    setState(() {
      final existingIndex =
          _cartItems.indexWhere((item) => item.productId == product.id);
      if (existingIndex >= 0) {
        final existing = _cartItems[existingIndex];
        if (existing.qty < product.stock) {
          final newQty = existing.qty + 1;
          _cartItems[existingIndex] = existing.copyWith(
            qty: newQty,
            subtotal: newQty * existing.sellPrice,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stok tidak cukup')),
          );
        }
      } else {
        _cartItems.add(
          TransactionItem(
            productId: product.id,
            product: product,
            qty: 1,
            sellPrice: product.sellPrice,
            subtotal: product.sellPrice,
          ),
        );
      }
      _cashController.clear();
    });
  }

  void _updateQuantity(int index, int newQty) {
    if (newQty <= 0) {
      _removeFromCart(index);
      return;
    }

    final item = _cartItems[index];
    final availableStock = item.product?.stock ?? 0;
    if (newQty > availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok tidak mencukupi')),
      );
      return;
    }

    setState(() {
      _cartItems[index] = item.copyWith(
        qty: newQty,
        subtotal: newQty * item.sellPrice,
      );
      _cashController.clear();
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
      _cashController.clear();
    });
  }

  Future<void> _processTransaction() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong')),
      );
      return;
    }

    if (_cash < _total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uang tunai tidak mencukupi')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final transaction = Transaction(
        date: DateTime.now(),
        total: _subtotal,
        discount: _discount,
        finalAmount: _total,
        paymentMethod: 'tunai',
        status: 'completed',
        items: _cartItems,
      );

      await _transactionService.createTransaction(transaction);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  List<Product> get _filteredProducts {
    final query = _productSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              (product.category?.name ?? '').toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSidebarScaffold(
      title: 'Transaksi',
      activeMenu: 'Transaksi',
      child: Container(
        color: const Color(0xFFF4F6FB),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              const SizedBox(height: 24),
              if (_isLoadingProducts)
                const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                _buildErrorState()
              else
                _buildContentLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Text(
            'Transaksi',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _startNewTransaction,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Transaksi Baru'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1100;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildCartCard(),
                    const SizedBox(height: 20),
                    _buildProductBrowser(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 350,
                child: _buildSummaryCard(),
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 20),
            _buildCartCard(),
            const SizedBox(height: 20),
            _buildProductBrowser(),
          ],
        );
      },
    );
  }

  Widget _buildCartCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: const [
                Icon(Icons.shopping_basket_outlined, color: Color(0xFF1F2937)),
                SizedBox(width: 12),
                Text(
                  'Keranjang Belanja',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _cartItems.isEmpty
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Keranjang kosong',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cartItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          final product = item.product;
                          return _buildCartItemTile(
                            item: item,
                            product: product,
                            index: index,
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemTile({
    required TransactionItem item,
    required Product? product,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Produk',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(item.sellPrice),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hapus',
                onPressed: () => _removeFromCart(index),
                icon:
                    const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    _buildQtyButton(
                      icon: Icons.remove,
                      onPressed: () => _updateQuantity(index, item.qty - 1),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      child: Text(
                        item.qty.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildQtyButton(
                      icon: Icons.add,
                      onPressed: () => _updateQuantity(index, item.qty + 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  _formatPrice(item.subtotal),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          if (product != null) ...[
            const SizedBox(height: 8),
            Text(
              'Stok tersedia: ${product.stock}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
      ),
    );
  }

  Widget _buildProductBrowser() {
    final filteredProducts = _filteredProducts;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Produk Tersedia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _productSearchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF5F42E6), width: 1.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (filteredProducts.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'Produk tidak ditemukan atau stok habis.',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 16.0;
                final maxWidth = constraints.maxWidth;
                final cardWidth = _calculateProductCardWidth(maxWidth, spacing);
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: filteredProducts
                      .map(
                        (product) => SizedBox(
                          width: cardWidth,
                          child: _buildProductCard(product),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  double _calculateProductCardWidth(double maxWidth, double spacing) {
    if (maxWidth <= 320) return maxWidth;
    final columns = (maxWidth / 240).floor().clamp(1, 4);
    final totalSpacing = spacing * (columns - 1);
    return (maxWidth - totalSpacing) / columns;
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.category?.name ?? '-',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 10),
          Text(
            _formatPrice(product.sellPrice),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF5F42E6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Stok: ${product.stock}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addToCart(product),
              icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F42E6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final change = _change;
    final changeColor =
        change >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.receipt_long_outlined, color: Color(0xFF1F2937)),
              SizedBox(width: 12),
              Text(
                'Ringkasan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryRow('Subtotal', _formatPrice(_subtotal)),
          const SizedBox(height: 18),
          const Text(
            'Diskon',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDiscountOption(
                label: 'Nominal',
                value: false,
              ),
              const SizedBox(width: 16),
              _buildDiscountOption(
                label: 'Persen',
                value: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: _isDiscountPercentage ? '0' : 'Rp 0',
              prefixText: _isDiscountPercentage ? '' : 'Rp ',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF5F42E6), width: 1.4),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          _buildSummaryRow(
            'Total',
            _formatPrice(_total),
            valueStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xFF5F42E6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tunai',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cashController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: 'Rp 0',
              prefixText: 'Rp ',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF5F42E6), width: 1.4),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          _buildSummaryRow(
            'Kembalian',
            _formatPrice(change),
            valueStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: changeColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _processTransaction,
              icon: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isProcessing ? 'Memproses...' : 'Proses Pembayaran',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F42E6),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountOption({required String label, required bool value}) {
    return InkWell(
      onTap: () {
        setState(() {
          _isDiscountPercentage = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<bool>(
            value: value,
            groupValue: _isDiscountPercentage,
            activeColor: const Color(0xFF5F42E6),
            onChanged: (_) {
              setState(() {
                _isDiscountPercentage = value;
              });
            },
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Terjadi kesalahan saat memuat data',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFEF4444)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F42E6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    final priceStr = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    return 'Rp $buffer';
  }
}
