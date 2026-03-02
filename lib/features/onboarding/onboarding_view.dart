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
    [Color(0xFFF5F0FF), Color(0xFFEDE9FE), Color(0xFFFFFFFF)],
    [Color(0xFFE8F5E9), Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
    [Color(0xFFFCE4EC), Color(0xFFEDE7F6), Color(0xFFFFFFFF)],
  ];

  final List<Color> _accentColors = [
    Color(0xFF8B5CF6),
    Color(0xFF059669),
    Color(0xFFDB2777),
  ];

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColors[step - 1];
    final gradient = _pageGradients[step - 1];

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
          child: Padding(
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Image container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.12),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    images[step - 1],
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 40),

                // Step indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isActive = step - 1 == index;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: isActive ? 28 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isActive ? accent : accent.withValues(alpha: 0.2),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 36),

                // Description text
                Text(
                  descriptions[step - 1],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.6,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),

                const Spacer(),

                // Next button
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      step == 3 ? 'Mulai Sekarang' : 'Lanjut',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}