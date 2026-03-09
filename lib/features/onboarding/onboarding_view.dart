import 'package:flutter/material.dart';
import 'package:logbook_app_088/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  final List<String> images = [
    'assets/images/onboarding/onboarding_1_welcome.png',
    'assets/images/onboarding/onboarding_2_counter.png',
    'assets/images/onboarding/onboarding_3_login.png',
  ];

  final List<String> descriptions = [
    'Selamat datang di Logbook App!\nCatat aktivitasmu dengan mudah.',
    'Gunakan tombol + dan - untuk menambah atau mengurangi hitungan.',
    'Login untuk menyimpan data pribadi dan riwayat aktivitasmu.',
  ];

  final List<List<Color>> _pageGradients = [
    [Color(0xFFF5F0FF), Color(0xFFEDE9FE), Color(0xFFE9E5FF)],
    [Color(0xFFE0F5F1), Color(0xFFD4F1ED), Color(0xFFE8F5F0)],
    [Color(0xFFFCE4EC), Color(0xFFF8D4E6), Color(0xFFFFCCD5)],
  ];

  final List<Color> _accentColors = [
    Color(0xFF8B5CF6),
    Color(0xFF059669),
    Color(0xFFDB2777),
  ];

  final List<List<Color>> _blobColors = [
    [Color(0xFF8B5CF6), Color(0xFFDB2777)],
    [Color(0xFF059669), Color(0xFF10B981)],
    [Color(0xFFDB2777), Color(0xFFF472B6)],
  ];

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  Widget _buildBlob(double size, Color color, {double opacity = 0.08}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final accent = _accentColors[step - 1];
    final gradient = _pageGradients[step - 1];
    final blobs = _blobColors[step - 1];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative blobs
              Positioned(
                right: -40,
                top: -30,
                child: _buildBlob(150, blobs[0], opacity: 0.1),
              ),
              Positioned(
                left: -50,
                bottom: 100,
                child: _buildBlob(120, blobs[1], opacity: 0.08),
              ),
              Positioned(
                right: 20,
                bottom: -40,
                child: _buildBlob(100, blobs[0], opacity: 0.07),
              ),
              
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Skip button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _goToLogin,
                        child: Text(
                          'Lewati',
                          style: TextStyle(
                            color: accent.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Image container with animation
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Container(
                        key: ValueKey(step),
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.15),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.12),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          images[step - 1],
                          height: 240,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Step indicators with better styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = step - 1 == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: isActive ? 32 : 12,
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                isActive ? accent : accent.withValues(alpha: 0.15),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: accent.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 44),

                    // Description text with animation
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        descriptions[step - 1],
                        key: ValueKey(step),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.7,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Next button with better styling
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (step >= 3) {
                            _goToLogin();
                          } else {
                            setState(() {
                              step++;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: accent.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          step == 3 ? 'Mulai Sekarang' : 'Lanjut',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}