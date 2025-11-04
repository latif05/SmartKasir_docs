import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/product_management_screen.dart';
import '../screens/category_management_screen.dart';
import '../screens/transaction_list_screen.dart';
import '../screens/report_screen.dart';
import '../screens/settings_screen.dart';

class ResponsiveSidebarScaffold extends StatefulWidget {
  final String title;
  final String
      activeMenu; // 'Dashboard' | 'Produk' | 'Kategori' | 'Transaksi' | 'Laporan' | 'Pengaturan'
  final Widget child;

  const ResponsiveSidebarScaffold({
    Key? key,
    required this.title,
    required this.activeMenu,
    required this.child,
  }) : super(key: key);

  @override
  State<ResponsiveSidebarScaffold> createState() =>
      _ResponsiveSidebarScaffoldState();
}

class _ResponsiveSidebarScaffoldState extends State<ResponsiveSidebarScaffold> {
  bool _isSidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1200;
        final isTablet = width >= 600 && width < 1200;
        final isMobile = width < 600;

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
                    _buildTopNavBar(isMobile, isTablet),
                    Expanded(child: widget.child),
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
      padding:
          EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
            icon: Icon(Icons.menu, color: Color(0xFF558080)),
          ),
          SizedBox(width: isMobile ? 8 : 20),
          Text(widget.title,
              style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF558080))),
          Spacer(),
          CircleAvatar(
              backgroundColor: Color(0xFF558080),
              radius: isMobile ? 16 : 20,
              child: Icon(Icons.person,
                  color: Colors.white, size: isMobile ? 18 : 24)),
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
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Color(0xFF558080)),
            child: Row(children: [
              Icon(Icons.store, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text('SmartKasir',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: [
              _navItem(Icons.dashboard, 'Dashboard',
                  widget.activeMenu == 'Dashboard', iconSize, fontSize, () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => DashboardScreen()));
              }),
              _navItem(Icons.inventory, 'Produk', widget.activeMenu == 'Produk',
                  iconSize, fontSize, () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductManagementScreen()));
              }),
              _navItem(Icons.category, 'Kategori',
                  widget.activeMenu == 'Kategori', iconSize, fontSize, () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CategoryManagementScreen()));
              }),
              _navItem(Icons.receipt, 'Transaksi',
                  widget.activeMenu == 'Transaksi', iconSize, fontSize, () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => TransactionListScreen()));
              }),
              _navItem(Icons.analytics, 'Laporan',
                  widget.activeMenu == 'Laporan', iconSize, fontSize, () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => ReportScreen()));
              }),
              _navItem(Icons.settings, 'Pengaturan',
                  widget.activeMenu == 'Pengaturan', iconSize, fontSize, () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()));
              }),
              Divider(),
              _navItem(Icons.logout, 'Logout', false, iconSize, fontSize, () {
                Navigator.of(context).pushReplacementNamed('/login');
              }),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, bool isActive, double iconSize,
      double fontSize, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color:
            isActive ? Color(0xFF558080).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isActive ? Color(0xFF558080) : Colors.grey[600],
            size: iconSize),
        title: Text(title,
            style: TextStyle(
                color: isActive ? Color(0xFF558080) : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: fontSize)),
        onTap: onTap,
      ),
    );
  }
}
