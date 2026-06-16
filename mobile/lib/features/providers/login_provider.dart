// lib/presentation/providers/auth_provider.dart
//
// Setara dengan state Formik di Next.js:
//   isSubmitting  → loginStateProvider saat loading
//   errors        → errorMessage di LoginState
//   onSubmit      → login() method di LoginNotifier

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';

// ── State: kondisi form login ────────────────────────────────────────────────
// Setara dengan state internal Formik (isSubmitting, errors, dll)
class LoginState {
  final bool isLoading; // setara isSubmitting di Formik
  final String? errorMessage; // setara errors.general
  final bool isSuccess; // setara result?.ok di NextAuth

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  // Bikin copy state dengan field yang berubah
  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // null = tidak ada error
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ── Notifier: logika submit login ────────────────────────────────────────────
// Setara dengan onSubmit di Formik Next.js
class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _repo;
  final Ref _ref; // ← tambah ini
  LoginNotifier(this._repo, this._ref) : super(const LoginState());

  Future<void> login(String username, String password) async {
    // 1. Set loading = true (setara isSubmitting = true di Formik)
    state = state.copyWith(isLoading: true);

    try {
      // 2. Kirim request ke backend Go
      //    Setara dengan: signIn("credentials", { payload: encrypted })
      final token = await _repo.login(
        LoginRequest(username: username, password: password),
      );
      _ref.read(authTokenProvider.notifier).state =
          token.accessToken; // ← 1 baris ini
      // 3. Sukses! (setara dengan toast "Selamat datang 👋")
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      // 4. Gagal → simpan pesan error (setara toast "Username atau password salah")
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Reset state (setara resetForm() di Formik)
  void reset() => state = const LoginState();
}

// Provider yang diakses dari widget
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.read(authRepositoryProvider), ref);
});

final authTokenProvider = StateProvider<String>((ref) => '');
