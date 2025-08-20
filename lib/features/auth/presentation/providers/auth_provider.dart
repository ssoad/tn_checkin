import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/providers/providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_out.dart';

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

  AuthNotifier({
    required GetCurrentUser getCurrentUser,
    required SignOut signOut,
  })  : _getCurrentUser = getCurrentUser,
        _signOut = signOut,
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
  return AuthNotifier(
    getCurrentUser: ref.read(getCurrentUserProvider),
    signOut: ref.read(signOutProvider),
  );
});
