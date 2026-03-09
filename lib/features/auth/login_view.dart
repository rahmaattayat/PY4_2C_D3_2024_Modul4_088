import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbook_app_088/features/auth/login_controller.dart';
import 'package:logbook_app_088/features/logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _obscurePassword = true;
  String? _errorMessage;

  bool _isBlocked = false;
  int _remainingSeconds = 0;
  Timer? _blockTimer;

  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _darkPurple = Color(0xFF4C1D95);

  Widget _buildBlob(double size, Color color, {double opacity = 0.08}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      );

  @override
  void dispose() {
    _blockTimer?.cancel();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _startBlockTimer() {
    setState(() {
      _isBlocked = true;
      _remainingSeconds = 10;
    });

    _blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _isBlocked = false;
          _remainingSeconds = 0;
          _controller.resetBlock();
          timer.cancel();
        }
      });
    });
  }

  void _handleLogin() {
    setState(() {
      _errorMessage = null;
    });

    final username = _userController.text.trim();
    final password = _passController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Username dan password tidak boleh kosong!";
      });
      return;
    }

    final result = _controller.login(username, password);

    if (result == LoginResult.success) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LogView(username: username), 
        ),
      );
    } else if (result == LoginResult.blocked) {
      _startBlockTimer();
      setState(() {
        _errorMessage = "Terlalu banyak percobaan. Tunggu $_remainingSeconds detik.";
      });
    } else {
      setState(() {
        _errorMessage = "Username atau password salah! (${_controller.failedAttempts}/3)";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? "Login Gagal!"),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F0FF),
              Color(0xFFEDE9FE),
              Color(0xFFF0EBFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative blobs
              Positioned(
                right: -60,
                top: -40,
                child: _buildBlob(200, _primaryPurple, opacity: 0.09),
              ),
              Positioned(
                left: -80,
                top: 100,
                child:
                    _buildBlob(150, const Color(0xFFDB2777), opacity: 0.07),
              ),
              Positioned(
                right: -40,
                bottom: -50,
                child: _buildBlob(180, _primaryPurple, opacity: 0.08),
              ),
              Positioned(
                left: 20,
                bottom: 150,
                child: _buildBlob(80, const Color(0xFFDB2777), opacity: 0.06),
              ),

              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Icon area with better shadow
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: _primaryPurple,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryPurple.withValues(alpha: 0.35),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.book_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Logbook App',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _darkPurple,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Masuk untuk melanjutkan',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Card form with better styling
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: _primaryPurple.withValues(alpha: 0.12),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryPurple.withValues(alpha: 0.1),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username field
                            const Text(
                              'Username',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _darkPurple,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _userController,
                              enabled: !_isBlocked,
                              style: const TextStyle(
                                fontSize: 15,
                                color: _darkPurple,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Masukkan username',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: _primaryPurple,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFAF8FE),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _primaryPurple,
                                    width: 2,
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Password field
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _darkPurple,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _passController,
                              obscureText: _obscurePassword,
                              enabled: !_isBlocked,
                              style: const TextStyle(
                                fontSize: 15,
                                color: _darkPurple,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Masukkan password',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: _primaryPurple,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _primaryPurple.withValues(alpha: 0.7),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFAF8FE),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _primaryPurple,
                                    width: 2,
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),

                            // Error message with animation
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFFDC2626),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Login button with animated state
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isBlocked ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isBlocked
                                      ? Colors.grey.shade300
                                      : _primaryPurple,
                                  foregroundColor: Colors.white,
                                  elevation: _isBlocked ? 0 : 8,
                                  shadowColor: _primaryPurple.withValues(
                                    alpha: 0.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: _isBlocked
                                      ? Row(
                                          key: const ValueKey('blocked'),
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.lock_clock_outlined,
                                              size: 18,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "Tunggu $_remainingSeconds s",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          key: ValueKey('active'),
                                          "Masuk",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}