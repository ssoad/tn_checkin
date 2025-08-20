import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_in_with_email_and_password.dart';
import '../../domain/usecases/sign_up_with_email_and_password.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, error, isAuthenticated];
}

class AuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUser _getCurrentUser;
  final SignOut _signOut;
  final SignInWithEmailAndPassword _signInWithEmailAndPassword;
  final SignUpWithEmailAndPassword _signUpWithEmailAndPassword;

  AuthNotifier({
    required GetCurrentUser getCurrentUser,
    required SignOut signOut,
    required SignInWithEmailAndPassword signInWithEmailAndPassword,
    required SignUpWithEmailAndPassword signUpWithEmailAndPassword,
  }) : _getCurrentUser = getCurrentUser,
       _signOut = signOut,
       _signInWithEmailAndPassword = signInWithEmailAndPassword,
       _signUpWithEmailAndPassword = signUpWithEmailAndPassword,
       super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getCurrentUser(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
        isAuthenticated: false,
        user: null,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        error: null,
        isAuthenticated: true,
        user: user,
      ),
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _signOut(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        error: null,
        isAuthenticated: false,
        user: null,
      ),
    );
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _signInWithEmailAndPassword(
      SignInParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
        isAuthenticated: false,
        user: null,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        error: null,
        isAuthenticated: true,
        user: user,
      ),
    );
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    UserType userType,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _signUpWithEmailAndPassword(
      SignUpParams(
        email: email,
        password: password,
        name: name,
        userType: userType,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _getFailureMessage(failure),
        isAuthenticated: false,
        user: null,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        error: null,
        isAuthenticated: true,
        user: user,
      ),
    );
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is AuthFailure) return failure.message;
    if (failure is NetworkFailure) return failure.message;
    if (failure is LocationFailure) return failure.message;
    if (failure is PermissionFailure) return failure.message;
    return 'An unexpected error occurred';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // These will be injected from the core providers
  throw UnimplementedError('Auth provider should be overridden in main.dart');
});
