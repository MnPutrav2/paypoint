// lib/presentation/pages/login_page.dart
//
// Ini versi Flutter dari LoginForm Next.js kamu.
// Semua logika yang ada di Next.js sudah dipindahkan ke sini:
//
//   Formik initialValues     → TextEditingController
//   Formik validationSchema  → _validate() manual / validator di TextFormField
//   onSubmit                 → ref.read(loginProvider.notifier).login()
//   toast.promise            → SnackBar / LoadingOverlay
//   router.push(DASHBOARD)   → context.go('/home')
//   errors.username          → _usernameError
//   touched                  → _usernameTouched / _passwordTouched

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasir_offline/features/providers/login_provider.dart';
import 'package:kasir_offline/core/index.dart';

// Ganti dengan import dari project kamu yang asli
// import 'package:kasir_offline/core/index.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // ── Controller (setara initialValues di Formik) ──────────────────────────
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ── Visible password toggle ───────────────────────────────────────────────
  bool _passwordVisible = false;

  @override
  void dispose() {
    // Wajib dispose controller supaya tidak memory leak
    // Setara dengan cleanup di useEffect Next.js
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validasi (setara loginSchema Yup di Next.js) ─────────────────────────
  String? _validateUsername(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Username atau email tidak boleh kosong';
    }
    if (val.trim().length < 3) {
      return 'Minimal 3 karakter';
    }
    return null; // null = valid
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (val.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // ── Submit (setara onSubmit Formik + signIn NextAuth) ─────────────────────
  Future<void> _onSubmit() async {
    // Validasi form dulu — setara dengan Formik touched + errors
    if (!_formKey.currentState!.validate()) return;

    // Panggil provider untuk login ke backend Go
    await ref
        .read(loginProvider.notifier)
        .login(_usernameController.text.trim(), _passwordController.text);
  }

  // ── Toast sukses (setara toast "Selamat datang 👋") ──────────────────────
  void _showSuccessToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Selamat datang 👋'),
          ],
        ),
        backgroundColor: const Color(0xFF1F5D84),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Toast error (setara toast "Username atau password salah") ─────────────
  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Listen perubahan state (setara useEffect watch isSuccess/error) ──────
    // ref.listen dipanggil setiap kali loginProvider berubah
    ref.listen<LoginState>(loginProvider, (previous, next) {
      // Kalau sukses → toast + redirect ke /home
      // Setara dengan: router.push(ROUTE.DASHBOARD.ROOT)
      if (next.isSuccess) {
        _showSuccessToast();
        context.go('/home');
        ref.read(loginProvider.notifier).reset();
      }

      // Kalau error → tampilkan toast error
      // Setara dengan: toast.promise error "Username atau password salah"
      if (next.errorMessage != null) {
        _showErrorToast(next.errorMessage!);
      }
    });

    // Baca state loading untuk disable tombol & tampilkan spinner
    final loginState = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // AppColors.backgroundCard
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey, // setara <Formik> wrapper di Next.js
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LOGO + JUDUL (sama persis dengan kode Flutter aslimu) ──
                Center(
                  child: Column(
                    children: [
                      // Image.asset('assets/logo/icon-white.png', height: 80),
                      const Icon(
                        Icons.storefront,
                        size: 80,
                        color: Color(0xFF1F5D84),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in',
                        style: GoogleFonts.audiowide(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F5D84),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Masuk ke akun',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // ── TIDAK PUNYA AKUN? (AppAuthRedirect) ──────────────────
                Row(
                  children: [
                    const Text(
                      'Tidak punya akun',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── INPUT EMAIL/USERNAME (AppTextField) ───────────────────
                // Setara dengan <FieldInput name="username"> di Next.js
                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next, // pindah ke password
                  enabled: !loginState.isLoading, // disable saat loading
                  validator: _validateUsername, // validasi saat submit
                  decoration: _inputDecoration(
                    hint: 'Email',
                    icon: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 12),

                // ── INPUT PASSWORD (AppTextField isPassword) ──────────────
                // Setara dengan <FieldPassword name="password"> di Next.js
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible, // sembunyikan teks password
                  textInputAction: TextInputAction.done,
                  enabled: !loginState.isLoading,
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _onSubmit(), // enter = submit
                  decoration: _inputDecoration(
                    hint: 'Kata sandi',
                    icon: Icons.lock_outline,
                    // Tombol show/hide password (tidak ada di Next.js tapi UX lebih baik)
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _passwordVisible = !_passwordVisible);
                      },
                    ),
                  ),
                ),

                // ── LUPA KATA SANDI ───────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: context.push('/forgot-password')
                    },
                    child: const Text(
                      'Lupa kata sandi ?',
                      style: TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── TOMBOL LOGIN (AppButton) ──────────────────────────────
                // Setara dengan <ButtonGrad type="submit"> di Next.js
                // + loading state setara isSubmitting Formik
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loginState.isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5D84),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF1F5D84,
                      ).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: loginState.isLoading
                        // Saat loading: spinner (setara toast "Memverifikasi akun...")
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── DIVIDER (sama dengan di Next.js) ──────────────────────
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                    Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  ],
                ),

                const SizedBox(height: 16),

                // ── DAFTAR SEKARANG ───────────────────────────────────────
                // Setara dengan Link ke ROUTE.AUTH.REGISTER.ROOT
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Belum punya akun? ',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.push('/signup'),
                            child: const Text(
                              'Daftar sekarang',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper: dekorasi input yang konsisten ─────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1F5D84), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }
}
