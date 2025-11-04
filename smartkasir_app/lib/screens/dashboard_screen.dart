import 'package:flutter/material.dart';
import 'category_management_screen.dart';
import 'product_management_screen.dart';
import 'transaction_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1200;
        final isTablet = width >= 600 && width < 1200;
        final isMobile = width < 600;
        
        // Auto-open sidebar on desktop
        if (isDesktop && !_isSidebarOpen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _isSidebarOpen = true);
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FB),
          body: Row(
            children: [
              // Sidebar
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _isSidebarOpen ? (isMobile ? 200 : 250) : 0,
                child: _isSidebarOpen ? _buildSidebar(isMobile) : Container(),
              ),
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    // Top Navigation Bar
                    _buildTopNavBar(isMobile, isTablet),
                    // Dashboard Content
                    Expanded(
                      child: _buildDashboardContent(isMobile, isTablet, isDesktop),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopNavBar(bool isMobile, bool isTablet) {
    final horizontalPadding = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final titleSize = isMobile ? 18.0 : (isTablet ? 20.0 : 24.0);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu Button
          IconButton(
            onPressed: () {
              setState(() {
                _isSidebarOpen = !_isSidebarOpen;
              });
            },
            icon: Icon(Icons.menu, color: Color(0xFF558080)),
          ),
          SizedBox(width: isMobile ? 8 : 20),
          // App Title
          Text(
            'SmartKasir',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Color(0xFF558080),
            ),
          ),
          Spacer(),
          // User Info (placeholder)
          CircleAvatar(
            backgroundColor: Color(0xFF558080),
            radius: isMobile ? 16 : 20,
            child: Icon(Icons.person, color: Colors.white, size: isMobile ? 18 : 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isMobile) {
    final fontSize = isMobile ? 14.0 : 16.0;
    final iconSize = isMobile ? 20.0 : 24.0;
    
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF558080),
            ),
            child: Row(
              children: [
                Icon(Icons.store, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  'SmartKasir',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(Icons.dashboard, 'Dashboard', false, iconSize, fontSize),
                _buildNavItem(Icons.inventory, 'Produk', true, iconSize, fontSize),
                _buildNavItem(Icons.category, 'Kategori', false, iconSize, fontSize),
                _buildNavItem(Icons.receipt, 'Transaksi', false, iconSize, fontSize),
                _buildNavItem(Icons.analytics, 'Laporan', false, iconSize, fontSize),
                _buildNavItem(Icons.settings, 'Pengaturan', false, iconSize, fontSize),
                Divider(),
                _buildNavItem(Icons.logout, 'Logout', false, iconSize, fontSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isActive, double iconSize, double fontSize) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF558080).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Color(0xFF558080) : Colors.grey[600],
          size: iconSize,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Color(0xFF558080) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        onTap: () {
          // Implement navigation
          if (title == 'Produk') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductManagementScreen()),
            );
          } else if (title == 'Kategori') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryManagementScreen()),
            );
          } else if (title == 'Transaksi') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransactionListScreen()),
            );
          } else if (title == 'Logout') {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
      ),
    );
  }

  Widget _buildDashboardContent(bool isMobile, bool isTablet, bool isDesktop) {
    final padding = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final titleSize = isMobile ? 22.0 : (isTablet ? 26.0 : 28.0);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Color(0xFF558080),
            ),
          ),
          SizedBox(height: isMobile ? 20 : 30),
          
          // KPI Cards
          _buildKPICards(isMobile, isTablet, isDesktop),
          SizedBox(height: isMobile ? 20 : 30),
          
          // Action Buttons
          _buildActionButtons(isMobile, isTablet, isDesktop),
          SizedBox(height: isMobile ? 20 : 30),
          
          // Recent Transactions
          _buildRecentTransactions(isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildKPICards(bool isMobile, bool isTablet, bool isDesktop) {
    final spacing = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    
    if (isMobile) {
      // Stack vertically on mobile
      return Column(
        children: [
          _buildKPICard('Total Penjualan Hari Ini', 'Rp 1.250.000', Icons.attach_money, isMobile),
          SizedBox(height: spacing),
          _buildKPICard('Jumlah Produk', '24', Icons.inventory, isMobile),
          SizedBox(height: spacing),
          _buildKPICard('Transaksi Hari Ini', '17', Icons.receipt, isMobile),
        ],
      );
    }
    
    // Horizontal layout for tablet and desktop
    return Row(
      children: [
        Expanded(
          child: _buildKPICard('Total Penjualan Hari Ini', 'Rp 1.250.000', Icons.attach_money, isMobile),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildKPICard('Jumlah Produk', '24', Icons.inventory, isMobile),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildKPICard('Transaksi Hari Ini', '17', Icons.receipt, isMobile),
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, bool isMobile) {
    final padding = isMobile ? 16.0 : 20.0;
    final iconSize = isMobile ? 20.0 : 24.0;
    final titleSize = isMobile ? 12.0 : 14.0;
    final valueSize = isMobile ? 20.0 : 24.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF558080), size: iconSize),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: titleSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: Color(0xFF558080),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isMobile, bool isTablet, bool isDesktop) {
    final spacing = isMobile ? 10.0 : 15.0;
    
    if (isMobile) {
      // Stack vertically on mobile
      return Column(
        children: [
          _buildActionButton('Transaksi Baru', Icons.add_shopping_cart, () {}, isMobile),
          SizedBox(height: spacing),
          _buildActionButton('Tambah Produk', Icons.add_box, () {}, isMobile),
          SizedBox(height: spacing),
          _buildActionButton('Lihat Laporan', Icons.analytics, () {}, isMobile),
        ],
      );
    }
    
    // Horizontal layout for tablet and desktop
    return Row(
      children: [
        Expanded(
          child: _buildActionButton('Transaksi Baru', Icons.add_shopping_cart, () {}, isMobile),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildActionButton('Tambah Produk', Icons.add_box, () {}, isMobile),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildActionButton('Lihat Laporan', Icons.analytics, () {}, isMobile),
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap, bool isMobile) {
    final padding = isMobile ? 12.0 : 15.0;
    final iconSize = isMobile ? 18.0 : 20.0;
    final fontSize = isMobile ? 14.0 : 16.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMobile ? double.infinity : null,
        padding: EdgeInsets.symmetric(vertical: padding, horizontal: isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Color(0xFF558080),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: iconSize),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(bool isMobile, bool isTablet) {
    final titleSize = isMobile ? 18.0 : (isTablet ? 19.0 : 20.0);
    final padding = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final fontSize = isMobile ? 12.0 : 14.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Transaksi Terbaru',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Color(0xFF558080),
          ),
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(flex: isMobile ? 2 : 2, child: Text('Waktu', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: fontSize))),
                    Expanded(flex: isMobile ? 3 : 3, child: Text('Produk', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: fontSize))),
                    Expanded(flex: isMobile ? 3 : 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: fontSize), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              // Table Rows
              _buildTransactionRow('09:10', 'Teh Botol x2', 'Rp 14.000', padding, fontSize, isMobile),
              _buildTransactionRow('09:25', 'Roti Tawar x1', 'Rp 12.000', padding, fontSize, isMobile),
              _buildTransactionRow('10:02', 'Kopi Sachet x3', 'Rp 21.000', padding, fontSize, isMobile),
              _buildTransactionRow('10:15', 'Indomie Goreng x5', 'Rp 50.000', padding, fontSize, isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionRow(String time, String product, String total, double padding, double fontSize, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: isMobile ? 2 : 2, child: Text(time, style: TextStyle(color: Colors.grey[600], fontSize: fontSize))),
          Expanded(flex: isMobile ? 3 : 3, child: Text(product, style: TextStyle(color: Colors.grey[600], fontSize: fontSize))),
          Expanded(flex: isMobile ? 3 : 2, child: Text(total, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: fontSize), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
