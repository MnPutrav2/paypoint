// lib/presentation/providers/register_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';

// ── State ────────────────────────────────────────────────────────────────────
class RegisterState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────
class RegisterNotifier extends StateNotifier<RegisterState> {
  final AuthRepository _repo;

  RegisterNotifier(this._repo) : super(const RegisterState());

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repo.register(
        RegisterRequest(
          email: email,
          password: password,
          confirmPassword: confirmPassword,
        ),
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void reset() => state = const RegisterState();
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) {
    return RegisterNotifier(ref.read(authRepositoryProvider));
  },
);
