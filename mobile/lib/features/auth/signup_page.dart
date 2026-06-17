// lib/presentation/pages/signup_page.dart
//
// Versi Flutter dari SignupPage kamu.
// Fitur yang ditambahkan vs versi asal:
//   ✅ Validasi email format
//   ✅ Validasi password minimal 6 karakter
//   ✅ Validasi confirm password harus sama
//   ✅ Loading state saat proses register
//   ✅ Toast sukses / error
//   ✅ Setelah sukses → kembali ke login (context.pop())
//   ✅ Disable semua input saat loading

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/register_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  // ── Controllers (satu per field) ─────────────────────────────────────────
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _emailController.dispose();
    _phoneNumber.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // ── Validasi email ────────────────────────────────────────────────────────
  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    // Regex sederhana cek format email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(val.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // ── Validasi password ─────────────────────────────────────────────────────
  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (val.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // ── Validasi confirm password (harus sama) ────────────────────────────────
  String? _validateConfirmPassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Ulangi password tidak boleh kosong';
    }
    // Bandingkan dengan field password
    if (val != _passwordController.text) {
      return 'Password tidak sama';
    }
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(registerProvider.notifier)
        .register(
          username: _username.text,
          name: _name.text,
          phoneNumber: _phoneNumber.text,
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPassController.text,
        );
  }

  void _showSuccessToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Akun berhasil dibuat! Silakan login 🎉'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

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
    // ── Listen state perubahan ────────────────────────────────────────────
    ref.listen<RegisterState>(registerProvider, (previous, next) {
      if (next.isSuccess) {
        _showSuccessToast();
        // Setelah sukses → kembali ke login (context.pop())
        // Sama persis dengan kode SignupPage aslimu
        context.pop();
        ref.read(registerProvider.notifier).reset();
      }
      if (next.errorMessage != null) {
        _showErrorToast(next.errorMessage!);
      }
    });

    final state = ref.watch(registerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // AppColors.backgroundCard
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LOGO + JUDUL ──────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.storefront,
                        size: 80,
                        color: Color(0xFF1F5D84),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign up',
                        style: GoogleFonts.audiowide(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(
                            0xFF1F5D84,
                          ), // AppColors.primaryDark
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Membuat akun kamu',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // ── SUDAH PUNYA AKUN? (AppAuthRedirect) ──────────────────
                Row(
                  children: [
                    const Text(
                      'Sudah punya akun',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => context.pop(), // kembali ke login
                      child: const Text(
                        'Sign in',
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

                // ── INPUT USERNAME ───────────────────────────────────────────
                TextFormField(
                  controller: _username,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isLoading,
                  decoration: _inputDecoration(
                    hint: 'Username',
                    icon: Icons.people,
                  ),
                ),

                const SizedBox(height: 12),

                // ── INPUT NAME ───────────────────────────────────────────
                TextFormField(
                  controller: _name,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isLoading,
                  decoration: _inputDecoration(
                    hint: 'Nama',
                    icon: Icons.people,
                  ),
                ),

                const SizedBox(height: 12),

                // ── INPUT EMAIL ───────────────────────────────────────────
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isLoading,
                  validator: _validateEmail,
                  decoration: _inputDecoration(
                    hint: 'Email',
                    icon: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 12),

                // ── INPUT Number ───────────────────────────────────────────
                TextFormField(
                  controller: _phoneNumber,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isLoading,
                  decoration: _inputDecoration(
                    hint: 'Nomor telepon',
                    icon: Icons.people,
                  ),
                ),

                const SizedBox(height: 12),

                // ── INPUT PASSWORD ────────────────────────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isLoading,
                  validator: _validatePassword,
                  decoration: _inputDecoration(
                    hint: 'Kata sandi',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── INPUT ULANGI PASSWORD ─────────────────────────────────
                TextFormField(
                  controller: _confirmPassController,
                  obscureText: !_confirmPasswordVisible,
                  textInputAction: TextInputAction.done,
                  enabled: !state.isLoading,
                  validator: _validateConfirmPassword,
                  onFieldSubmitted: (_) => _onSubmit(),
                  decoration: _inputDecoration(
                    hint: 'Ulangi kata sandi',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () =>
                            _confirmPasswordVisible = !_confirmPasswordVisible,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── TOMBOL SIGN UP (AppButton) ────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _onSubmit,
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
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── SUDAH PUNYA AKUN? (bawah) ─────────────────────────────
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? ',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: const Text(
                              'Sign in',
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