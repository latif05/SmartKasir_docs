import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameCtrl = TextEditingController();
  final _storeNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _loading = false;
  bool _agreeTerms = false;
  int _passwordStrengthLevel = 0; // 0-empty, 1-weak, 2-medium, 3-strong
  String _passwordStrengthLabel = '';

  final _backgroundGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B7FFB), Color(0xFF8A55E8)],
  );

  void _submit() async {
    setState(() => _loading = true);
    // TODO: Implement register logic
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    // TODO: Show success/failure dialog
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _storeNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF4B5E9A),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    const borderColor = Color(0xFFE0E7FF);
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: const Color(0xFF7A8CE8)),
      filled: true,
      fillColor: const Color(0xFFF5F7FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF7A8CE8), width: 1.4),
      ),
    );
  }

  Widget _buildPrimaryButton(double height) {
    final isDisabled = _loading || !_agreeTerms;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : _submit,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isDisabled
                ? const LinearGradient(
                    colors: [Color(0xFFB8C0FF), Color(0xFFD0C9F6)],
                  )
                : _backgroundGradient,
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF6B7FFB).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.6,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.person_add_alt_1, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _evaluatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordStrengthLevel = 0;
        _passwordStrengthLabel = '';
      });
      return;
    }

    int score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value) ||
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) score++;

    setState(() {
      if (score <= 1) {
        _passwordStrengthLevel = 1;
        _passwordStrengthLabel = 'Lemah';
      } else if (score == 2) {
        _passwordStrengthLevel = 2;
        _passwordStrengthLabel = 'Sedang';
      } else {
        _passwordStrengthLevel = 3;
        _passwordStrengthLabel = 'Kuat';
      }
    });
  }

  Widget _buildPasswordStrengthIndicator() {
    const inactiveColor = Color(0xFFE3E8FF);
    final activeColors = [
      const Color(0xFFF97316), // weak
      const Color(0xFFFACC15), // medium
      const Color(0xFF22C55E), // strong
    ];

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(3, (index) {
              final isActive = _passwordStrengthLevel > index;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isActive ? activeColors[index] : inactiveColor,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: _passwordStrengthLevel == 0
                ? const Color(0xFF94A3B8)
                : activeColors[_passwordStrengthLevel - 1],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          child: Text(
            _passwordStrengthLabel.isEmpty ? ' ' : _passwordStrengthLabel,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _backgroundGradient),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = width > 620 ? 560.0 : width - 40;
            final isSmall = width < 400;
            final buttonHeight = isSmall ? 48.0 : 56.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 16 : 24, vertical: 32),
                child: Container(
                  width: cardWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 28,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 38, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: _backgroundGradient,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32)),
                        ),
                        child: Column(
                          children: const [
                            _HeaderIcon(),
                            SizedBox(height: 20),
                            Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Buat akun untuk mulai menggunakan SmartKasir',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Nama Lengkap'),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _fullNameCtrl,
                              decoration: _inputDecoration(
                                hintText: 'Masukkan nama lengkap',
                                icon: Icons.person_outline,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Nama Toko/Usaha'),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _storeNameCtrl,
                              decoration: _inputDecoration(
                                hintText: 'Masukkan nama toko/usaha',
                                icon: Icons.storefront_outlined,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Email'),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDecoration(
                                hintText: 'Masukkan email',
                                icon: Icons.mail_outline,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Nomor Telepon'),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration(
                                hintText: '08xxxxxxxxxx',
                                icon: Icons.phone_outlined,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Nama Pemilik'),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _ownerNameCtrl,
                              decoration: _inputDecoration(
                                hintText: 'Masukkan nama pemilik',
                                icon: Icons.badge_outlined,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Password'),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              decoration: _inputDecoration(
                                hintText: 'Minimal 8 karakter',
                                icon: Icons.lock_outline,
                              ),
                              onChanged: _evaluatePassword,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            _buildPasswordStrengthIndicator(),
                            const SizedBox(height: 20),
                            _buildLabel('Konfirmasi Password'),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _confirmPasswordCtrl,
                              obscureText: true,
                              decoration: _inputDecoration(
                                hintText: 'Ulangi password',
                                icon: Icons.lock_person_outlined,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _agreeTerms,
                                  onChanged: (value) => setState(
                                      () => _agreeTerms = value ?? false),
                                  activeColor: const Color(0xFF6B7FFB),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        color: Color(0xFF5D6DAA),
                                        fontSize: 13.5,
                                        height: 1.4,
                                      ),
                                      children: [
                                        TextSpan(text: 'Saya menyetujui '),
                                        TextSpan(
                                          text: 'Syarat & Ketentuan',
                                          style: TextStyle(
                                            color: Color(0xFF6B7FFB),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(text: ' dan '),
                                        TextSpan(
                                          text: 'Kebijakan Privasi',
                                          style: TextStyle(
                                            color: Color(0xFF6B7FFB),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildPrimaryButton(buttonHeight),
                            const SizedBox(height: 24),
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Sudah punya akun? ',
                                    style: TextStyle(
                                      color: Color(0xFF5D6DAA),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Masuk disini',
                                      style: TextStyle(
                                        color: Color(0xFF6B7FFB),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      child: const Icon(
        Icons.point_of_sale_rounded,
        color: Colors.white,
        size: 38,
      ),
    );
  }
}
