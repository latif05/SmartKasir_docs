import 'package:flutter/material.dart';
import 'package:smartkasir_app/models/settings.dart';
import 'package:smartkasir_app/services/settings_service.dart';
import 'package:smartkasir_app/widgets/responsive_sidebar_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _service = SettingsService();

  final _storeNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _storeEmailCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  final _accountEmailCtrl = TextEditingController();
  final _accountPasswordCtrl = TextEditingController();
  final _minStockCtrl = TextEditingController();

  Settings? _settings;
  bool _loading = true;
  bool _savingStore = false;
  bool _savingAccount = false;
  bool _savingSystem = false;
  bool _processingDangerAction = false;
  String? _errorMessage;

  bool _offlineMode = false;
  bool _notifMinimumStock = true;
  bool _autoSync = true;
  String _receiptFormat = 'Struk dengan Header dan Footer';

  final List<String> _receiptFormatOptions = const [
    'Struk dengan Header dan Footer',
    'Struk Ringkas',
    'Struk Digital (Email)',
  ];

  @override
  void initState() {
    super.initState();
    _accountNameCtrl.addListener(() => setState(() {}));
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service.fetchSettings();
      _applySettingsToControllers(data);
      setState(() {
        _settings = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  void _applySettingsToControllers(Settings data) {
    _storeNameCtrl.text = data.storeName;
    _addressCtrl.text = data.storeAddress;
    _phoneCtrl.text = data.storePhone;
    _storeEmailCtrl.text = data.storeEmail;
    _accountNameCtrl.text = data.accountName;
    _accountEmailCtrl.text = data.accountEmail;
    _minStockCtrl.text = data.defaultMinStock.toString();
    _offlineMode = data.enableOfflineMode;
    _notifMinimumStock = data.enableLowStockNotification;
    _autoSync = data.enableAutoSync;
    _receiptFormat = data.receiptFormat.isNotEmpty
        ? data.receiptFormat
        : _receiptFormatOptions.first;
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _storeEmailCtrl.dispose();
    _accountNameCtrl.dispose();
    _accountEmailCtrl.dispose();
    _accountPasswordCtrl.dispose();
    _minStockCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveStoreInformation() async {
    if (_settings == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _savingStore = true);
    try {
      final updated = _settings!.copyWith(
        storeName: _storeNameCtrl.text.trim(),
        storeAddress: _addressCtrl.text.trim(),
        storePhone: _phoneCtrl.text.trim(),
        storeEmail: _storeEmailCtrl.text.trim(),
      );
      final saved = await _service.saveSettings(updated);
      setState(() {
        _settings = saved;
        _savingStore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informasi toko berhasil disimpan')),
      );
    } catch (e) {
      setState(() => _savingStore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan informasi toko: $e')),
      );
    }
  }

  Future<void> _saveAccountSettings() async {
    if (_settings == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _savingAccount = true);
    try {
      final updated = _settings!.copyWith(
        accountName: _accountNameCtrl.text.trim(),
        accountEmail: _accountEmailCtrl.text.trim(),
      );
      final saved = await _service.saveSettings(updated);
      setState(() {
        _settings = saved;
        _savingAccount = false;
      });
      final passwordMessage = _accountPasswordCtrl.text.trim().isEmpty
          ? null
          : 'Perubahan password belum tersinkronisasi (fitur coming soon).';
      _accountPasswordCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            passwordMessage ?? 'Pengaturan akun berhasil disimpan',
          ),
        ),
      );
    } catch (e) {
      setState(() => _savingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pengaturan akun: $e')),
      );
    }
  }

  Future<void> _saveSystemSettings() async {
    if (_settings == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _savingSystem = true);
    try {
      final minStock = int.tryParse(_minStockCtrl.text.trim());
      final updated = _settings!.copyWith(
        defaultMinStock: minStock ?? _settings!.defaultMinStock,
        enableOfflineMode: _offlineMode,
        enableLowStockNotification: _notifMinimumStock,
        enableAutoSync: _autoSync,
        receiptFormat: _receiptFormat,
      );
      final saved = await _service.saveSettings(updated);
      setState(() {
        _settings = saved;
        _savingSystem = false;
        if (minStock == null) {
          _minStockCtrl.text = saved.defaultMinStock.toString();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan sistem berhasil disimpan')),
      );
    } catch (e) {
      setState(() => _savingSystem = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pengaturan sistem: $e')),
      );
    }
  }

  Future<void> _handleResetDatabase() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Reset Database',
      message:
          'Tindakan ini akan mengosongkan data produk dan transaksi lokal. Lanjutkan?',
      confirmLabel: 'Ya, Reset',
    );
    if (!confirmed) return;

    setState(() => _processingDangerAction = true);
    try {
      await _service.resetDatabase();
      setState(() => _processingDangerAction = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database berhasil direset')),
      );
    } catch (e) {
      setState(() => _processingDangerAction = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mereset database: $e')),
      );
    }
  }

  Future<void> _handleClearAllData() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Hapus Semua Data',
      message:
          'Semua data lokal termasuk pengaturan akan dihapus permanen. Tindakan ini tidak dapat dibatalkan. Yakin ingin melanjutkan?',
      confirmLabel: 'Ya, Hapus',
    );
    if (!confirmed) return;

    setState(() => _processingDangerAction = true);
    try {
      await _service.clearAllData();
      setState(() => _processingDangerAction = false);
      await _loadSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data lokal berhasil dihapus')),
      );
    } catch (e) {
      setState(() => _processingDangerAction = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: $e')),
      );
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSidebarScaffold(
      title: 'Pengaturan',
      activeMenu: 'Pengaturan',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSettings,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Pengaturan'),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Informasi Toko',
            icon: Icons.storefront,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Nama Toko',
                  controller: _storeNameCtrl,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Alamat',
                  controller: _addressCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Telepon',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Email',
                        controller: _storeEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildPrimaryButton(
                    label: 'Simpan Perubahan',
                    loading: _savingStore,
                    onPressed: _saveStoreInformation,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Pengaturan Akun',
            icon: Icons.manage_accounts,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileAvatar(),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'Nama Lengkap',
                            controller: _accountNameCtrl,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Email',
                            controller: _accountEmailCtrl,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Password',
                            controller: _accountPasswordCtrl,
                            obscureText: true,
                            hintText:
                                'Kosongkan jika tidak ingin mengubah password',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildPrimaryButton(
                    label: 'Simpan Perubahan',
                    loading: _savingAccount,
                    onPressed: _saveAccountSettings,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Pengaturan Sistem',
            icon: Icons.settings,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Stok Minimum Default',
                  controller: _minStockCtrl,
                  keyboardType: TextInputType.number,
                  helperText:
                      'Notifikasi akan muncul ketika stok produk kurang dari nilai ini',
                ),
                const SizedBox(height: 16),
                _buildDropdownField(),
                const SizedBox(height: 12),
                _buildCheckbox(
                  value: _offlineMode,
                  label: 'Aktifkan mode offline',
                  onChanged: (value) =>
                      setState(() => _offlineMode = value ?? false),
                ),
                _buildCheckbox(
                  value: _notifMinimumStock,
                  label: 'Aktifkan notifikasi stok minimum',
                  onChanged: (value) =>
                      setState(() => _notifMinimumStock = value ?? false),
                ),
                _buildCheckbox(
                  value: _autoSync,
                  label: 'Aktifkan sinkronisasi otomatis',
                  onChanged: (value) =>
                      setState(() => _autoSync = value ?? false),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildPrimaryButton(
                    label: 'Simpan Pengaturan',
                    loading: _savingSystem,
                    onPressed: _saveSystemSettings,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDangerZone(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              color: const Color(0xFFF4F6FF),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF5F42E6)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF5F42E6), width: 1.5),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            helperText,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
    bool loading = false,
  }) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5F42E6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(label),
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Format Struk',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _receiptFormat,
          items: _receiptFormatOptions
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF5F42E6), width: 1.5),
            ),
          ),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _receiptFormat = value);
          },
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
      ),
      activeColor: const Color(0xFF5F42E6),
    );
  }

  Widget _buildProfileAvatar() {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF6B7FFB), Color(0xFF8A55E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              _accountNameCtrl.text.isNotEmpty
                  ? _accountNameCtrl.text.characters.first.toUpperCase()
                  : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur ganti foto belum tersedia'),
              ),
            );
          },
          icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF5F42E6)),
          label: const Text(
            'Ganti Foto',
            style: TextStyle(color: Color(0xFF5F42E6)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF5F42E6)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 12),
              Text(
                'Zona Bahaya',
                style: TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Aksi di bawah ini tidak dapat dibatalkan. Hati-hati dalam mengambil tindakan.',
            style: TextStyle(color: Color(0xFFB91C1C)),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildDangerButton(
                icon: Icons.refresh_rounded,
                label: 'Reset Database',
                onPressed:
                    _processingDangerAction ? null : _handleResetDatabase,
              ),
              _buildDangerButton(
                icon: Icons.delete_forever_rounded,
                label: 'Hapus Semua Data',
                onPressed: _processingDangerAction ? null : _handleClearAllData,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: _processingDangerAction
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF4444),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
