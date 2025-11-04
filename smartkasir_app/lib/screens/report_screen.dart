import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../widgets/responsive_sidebar_scaffold.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();
  List<SalesReportRow> _rows = [];
  bool _loading = true;
  String? _error;

  final DateTimeRange _defaultRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  late DateTimeRange _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = _defaultRange;
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final rows = await _reportService.getSalesReport(
        start: _formatDateParam(_selectedRange.start),
        end: _formatDateParam(_selectedRange.end),
      );
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
      helpText: 'Pilih rentang tanggal',
      confirmText: 'Terapkan',
      cancelText: 'Batal',
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
      await _load();
    }
  }

  String _formatDateParam(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatVisibleDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  double get _totalSales => _rows.fold(0, (sum, row) => sum + row.total);

  double get _averageBasket {
    if (_rows.isEmpty) return 0;
    return _totalSales / _rows.length;
  }

  int get _totalTransactions => _rows.length;

  int get _totalProductsSold =>
      _rows.fold(0, (sum, row) => sum + (row.profit + row.total).round());

  @override
  Widget build(BuildContext context) {
    return ResponsiveSidebarScaffold(
      title: 'Laporan',
      activeMenu: 'Laporan',
      child: Container(
        color: const Color(0xFFF4F6FB),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (_loading)
                const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _buildErrorState()
              else ...[
                _buildHighlightCards(),
                const SizedBox(height: 24),
                _buildChartsRow(),
                const SizedBox(height: 24),
                _buildTopProductsCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final startText = _formatVisibleDate(_selectedRange.start);
    final endText = _formatVisibleDate(_selectedRange.end);
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Laporan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        _DateDisplayButton(
          label: startText,
          onTap: _pickDateRange,
        ),
        const SizedBox(width: 12),
        _DateDisplayButton(
          label: endText,
          onTap: _pickDateRange,
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export PDF belum tersedia')),
            );
          },
          icon: const Icon(Icons.download, size: 20),
          label: const Text('Export PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5F42E6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final cards = [
          _HighlightCard(
            title: 'Total Penjualan',
            value: _formatCurrency(_totalSales),
            subtitle:
                'Periode: ${_formatVisibleDate(_selectedRange.start)} - ${_formatVisibleDate(_selectedRange.end)}',
            trendLabel: 'Rentang dipilih',
            icon: Icons.attach_money,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          _HighlightCard(
            title: 'Total Transaksi',
            value: _totalTransactions.toString(),
            subtitle: 'Dalam periode yang sama',
            trendLabel: 'Transaksi tercatat',
            icon: Icons.receipt_long,
            gradient: const LinearGradient(
              colors: [Color(0xFF22D3EE), Color(0xFF38BDF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          _HighlightCard(
            title: 'Rata-rata Belanja',
            value: _formatCurrency(_averageBasket),
            subtitle: 'Per transaksi',
            trendLabel: 'Per transaksi',
            icon: Icons.trending_up,
            gradient: const LinearGradient(
              colors: [Color(0xFF34D399), Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          _HighlightCard(
            title: 'Produk Terjual',
            value: _totalProductsSold.toString(),
            subtitle: 'Units terjual',
            trendLabel: 'Total units',
            icon: Icons.inventory_2_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ];

        if (isCompact) {
          return Column(
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cards
                    .map((card) => SizedBox(
                          width: constraints.maxWidth,
                          child: card,
                        ))
                    .toList(),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cards
              .map((card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: card,
                    ),
                  ))
              .toList()
            ..last = Expanded(child: cards.last),
        );
      },
    );
  }

  Widget _buildChartsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 960;
        return isStacked
            ? Column(
                children: [
                  _DummyChartCard(
                    title: 'Tren Penjualan',
                    description: 'Grafik penjualan 7 hari terakhir',
                    icon: Icons.show_chart,
                  ),
                  const SizedBox(height: 20),
                  _DummyCategoryChartCard(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _DummyChartCard(
                      title: 'Tren Penjualan',
                      description: 'Grafik penjualan 7 hari terakhir',
                      icon: Icons.show_chart,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: _DummyCategoryChartCard(),
                  ),
                ],
              );
      },
    );
  }

  Widget _buildTopProductsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '10 Produk Terlaris',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => const Color(0xFFF3F4F6),
                  ),
                  headingRowHeight: 48,
                  dataRowHeight: 52,
                  columnSpacing: 28,
                  columns: const [
                    DataColumn(label: _TableHeader('Rank')),
                    DataColumn(label: _TableHeader('Nama Produk')),
                    DataColumn(label: _TableHeader('Kategori')),
                    DataColumn(label: _TableHeader('Terjual')),
                    DataColumn(label: _TableHeader('Total Penjualan')),
                  ],
                  rows: _buildTopProductRows(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _buildTopProductRows() {
    final sampleTopProducts = <_TopProductSample>[
      _TopProductSample('Ayam Goreng', 'Makanan & Minuman', 147, 1764000.0),
      _TopProductSample('Nasi Goreng', 'Makanan & Minuman', 125, 1000000.0),
      _TopProductSample('Kopi Hitam', 'Makanan & Minuman', 98, 490000.0),
      _TopProductSample('Teh Manis', 'Makanan & Minuman', 87, 348000.0),
      _TopProductSample('Mie Goreng', 'Makanan & Minuman', 72, 504000.0),
      _TopProductSample('Sirup Jeruk', 'Minuman', 66, 660000.0),
      _TopProductSample('Gula Pasir', 'Sembako', 54, 432000.0),
      _TopProductSample('Minyak Goreng', 'Sembako', 48, 576000.0),
      _TopProductSample('Snack Kentang', 'Snack', 41, 205000.0),
      _TopProductSample('Air Mineral', 'Minuman', 39, 78000.0),
    ];

    return List.generate(sampleTopProducts.length, (index) {
      final entry = sampleTopProducts[index];
      return DataRow(
        cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(entry.productName)),
          DataCell(Text(entry.categoryName)),
          DataCell(Text('${entry.unitsSold} units')),
          DataCell(Text(_formatCurrency(entry.totalSales))),
        ],
      );
    });
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFEF4444)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _load,
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

  String _formatCurrency(double value) {
    final s = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }
}

class _DateDisplayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateDisplayButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_today_outlined, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1F2937),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String trendLabel;
  final IconData icon;
  final Gradient gradient;

  const _HighlightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trendLabel,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.2),
              size: 120,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  trendLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DummyChartCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _DummyChartCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF5F42E6)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: Center(
                  child: Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DummyCategoryChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = <_CategoryShareSample>[
      _CategoryShareSample('Makanan & Minuman', 45, const Color(0xFF6366F1)),
      _CategoryShareSample('Elektronik', 25, const Color(0xFF10B981)),
      _CategoryShareSample('Pakaian', 15, const Color(0xFFF59E0B)),
      _CategoryShareSample('Sembako', 15, const Color(0xFFEF4444)),
    ];

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pie_chart_outline, color: Color(0xFF5F42E6)),
              SizedBox(width: 12),
              Text(
                'Penjualan per Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFFF97316),
                          Color(0xFF10B981),
                          Color(0xFF6366F1),
                          Color(0xFFEF4444),
                        ],
                        stops: [0.3, 0.55, 0.8, 1],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '100%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories
                      .map((cat) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: cat.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${cat.name} (${cat.percentage}%)',
                                  style: const TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
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
        color: Color(0xFF4B5563),
        letterSpacing: 0.4,
      ),
    );
  }
}

class _TopProductSample {
  final String productName;
  final String categoryName;
  final int unitsSold;
  final double totalSales;

  const _TopProductSample(
    this.productName,
    this.categoryName,
    this.unitsSold,
    this.totalSales,
  );
}

class _CategoryShareSample {
  final String name;
  final int percentage;
  final Color color;

  const _CategoryShareSample(this.name, this.percentage, this.color);
}
