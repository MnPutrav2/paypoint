import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasir_offline/data/repositories/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _cekStatusLogin();
  }

  Future<void> _cekStatusLogin() async {
    // Tambahkan delay supaya splash screen sempat terlihat
    await Future.delayed(const Duration(seconds: 2));

    final repo = ref.read(authRepositoryProvider);
    final sudahLogin = await repo.isLoggedIn();

    if (!mounted) return; // ← cegah error jika widget sudah di-dispose
    if (sudahLogin) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF294B71), Color(0xFF12273E)],
              ),
            ),
          ),
          Center(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo/icon-white.png', height: 100),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'KAVI - Kasir',
                      style: GoogleFonts.audiowide(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -50,
            child: SafeArea(
              top: false,
              child: Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
