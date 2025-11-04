import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import 'product_form_screen.dart';
import 'category_management_screen.dart';
import '../widgets/responsive_sidebar_scaffold.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final products = await _productService.getProducts();
      final categories = await _categoryService.getCategories();

      setState(() {
        _products = products;
        _categories = categories;
        if (_selectedCategoryId != null &&
            !_categories.any((c) => c.id == _selectedCategoryId)) {
          _selectedCategoryId = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openProductForm({Product? product}) async {
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(
          product: product,
          categories: _categories,
        ),
      ),
    );
    if (refreshed == true) {
      _loadData();
    }
  }

  Future<void> _openCategoryManagement() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
    );
    await _loadData();
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await _productService.deleteProduct(product.id!);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk "${product.name}" berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus produk: $e')),
        );
      }
    }
  }

  void _confirmDelete(Product product) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text(
            'Apakah Anda yakin ingin menghapus produk "${product.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    final selectedId = _selectedCategoryId;
    final matches = _products.where((product) {
      final matchesCategory =
          selectedId == null || product.categoryId == selectedId;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;
      final categoryName = product.category?.name ?? '';
      final sku = product.id?.toString() ?? '';

      return product.name.toLowerCase().contains(query) ||
          categoryName.toLowerCase().contains(query) ||
          sku.toLowerCase().contains(query);
    }).toList();

    matches.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return matches;
  }

  String _formatCurrency(double value) {
    final digits = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return 'Rp $buffer';
  }

  String _formatProductId(Product product) {
    if (product.id == null) return '-';
    final idStr = product.id.toString();
    return 'P${idStr.padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSidebarScaffold(
      title: 'Produk',
      activeMenu: 'Produk',
      child: Container(
        color: const Color(0xFFF4F6FB),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              if (_isLoading)
                const SizedBox(
                  height: 260,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                _buildErrorState()
              else
                _buildProductTableCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 860;
        final controls = <Widget>[
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 16),
          _buildManageCategoriesButton(),
          const SizedBox(width: 12),
          _buildAddProductButton(),
        ];

        if (!isCompact) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controls,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchField(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildManageCategoriesButton()),
                const SizedBox(width: 12),
                _buildAddProductButton(),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari produk...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5F42E6), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildManageCategoriesButton() {
    return OutlinedButton.icon(
      onPressed: _openCategoryManagement,
      icon: const Icon(Icons.category_outlined, color: Color(0xFF5F42E6)),
      label: const Text(
        'Kelola Kategori',
        style: TextStyle(color: Color(0xFF5F42E6)),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF5F42E6)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAddProductButton() {
    return ElevatedButton.icon(
      onPressed: () => _openProductForm(),
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Tambah Produk'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5F42E6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildProductTableCard() {
    final products = _filteredProducts;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Daftar Produk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<int?>(
                    value: _selectedCategoryId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Semua Kategori'),
                      ),
                      ..._categories.map(
                        (category) => DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF5F42E6), width: 1.5),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          if (products.isEmpty)
            _buildTableEmptyState()
          else
            _buildDataTable(products),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Product> products) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith(
            (states) => const Color(0xFFF3F4F6),
          ),
          dataRowColor: MaterialStateProperty.resolveWith(
            (states) => Colors.white,
          ),
          headingRowHeight: 52,
          dataRowHeight: 56,
          horizontalMargin: 24,
          columnSpacing: 28,
          dividerThickness: 0.6,
          columns: const [
            DataColumn(label: _TableHeader('ID')),
            DataColumn(label: _TableHeader('Nama Produk')),
            DataColumn(label: _TableHeader('Kategori')),
            DataColumn(label: _TableHeader('Harga Beli')),
            DataColumn(label: _TableHeader('Harga Jual')),
            DataColumn(label: _TableHeader('Stok')),
            DataColumn(label: _TableHeader('Aksi')),
          ],
          rows: products.map((product) {
            final costPrice = product.costPrice;
            final sellPrice = product.sellPrice;
            return DataRow(
              cells: [
                DataCell(Text(
                  _formatProductId(product),
                  style: const TextStyle(color: Color(0xFF4B5563)),
                )),
                DataCell(Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                )),
                DataCell(Text(
                  product.category?.name ?? '-',
                  style: const TextStyle(color: Color(0xFF4B5563)),
                )),
                DataCell(Text(
                  costPrice == null ? '-' : _formatCurrency(costPrice),
                  style: const TextStyle(color: Color(0xFF6B7280)),
                )),
                DataCell(Text(
                  _formatCurrency(sellPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                )),
                DataCell(Text(
                  product.stock.toString(),
                  style: const TextStyle(color: Color(0xFF4B5563)),
                )),
                DataCell(
                  Row(
                    children: [
                      _ActionButton(
                        tooltip: 'Edit produk',
                        icon: Icons.edit_outlined,
                        color: const Color(0xFF5F42E6),
                        onTap: () => _openProductForm(product: product),
                      ),
                      const SizedBox(width: 10),
                      _ActionButton(
                        tooltip: 'Hapus produk',
                        icon: Icons.delete_outline,
                        color: const Color(0xFFEF4444),
                        onTap: () => _confirmDelete(product),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
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
            _errorMessage ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFEF4444)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F42E6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 64),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada produk yang ditampilkan',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan produk baru atau ubah filter pencarian.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: Color(0xFF4B5563),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
