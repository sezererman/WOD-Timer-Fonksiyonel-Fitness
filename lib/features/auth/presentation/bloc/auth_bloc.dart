import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/auth_validation_mixin.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/listen_auth_state_change_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/signout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> with AuthValidationMixin {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ListenAuthStateChangeUseCase _listenAuthStateChangeUseCase;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required ListenAuthStateChangeUseCase listenAuthStateChangeUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _listenAuthStateChangeUseCase = listenAuthStateChangeUseCase,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<_AuthStateChanged>(_onAuthStateChanged);

    // Giriş butonuna art arda basılmasını (Debouncing) engellemek için droppable() kullanılır.
    on<AuthLoginRequested>(
      _onAuthLoginRequested,
      transformer: droppable(),
    );

    on<AuthRegisterRequested>(
      _onAuthRegisterRequested,
      transformer: droppable(),
    );

    on<AuthSignOutRequested>(_onAuthSignOutRequested);

    // Supabase token süresi dolduğunda veya başka cihazdan logout olunduğunda
    // bu stream anında tetiklenir ve uygulama login ekranına yönlendirir.
    _authStateSubscription = _listenAuthStateChangeUseCase().listen(
      (user) => add(_AuthStateChanged(user)),
    );
  }

  Future<void> _onAppStarted(
      AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUserUseCase(const NoParams());
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  // Supabase onAuthStateChange stream'inden gelen değişiklikler
  void _onAuthStateChanged(
      _AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      // Token expire, remote logout vb. — login sayfasına yönlendir
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    final emailError = validateEmail(event.email);
    final passwordError = validatePassword(event.password);

    if (emailError != null || passwordError != null) {
      emit(const AuthError('E-posta veya şifre hatalı. (Validasyon hatası)'));
      return;
    }

    emit(AuthLoading());
    try {
      final user = await _loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );
      emit(Authenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } on CacheException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Beklenmeyen bir hata oluştu.'));
    }
  }

  Future<void> _onAuthRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    final emailError = validateEmail(event.email);
    if (emailError != null) {
      emit(AuthError(emailError));
      return;
    }

    final passwordError = validatePassword(event.password);
    if (passwordError != null) {
      emit(AuthError(passwordError));
      return;
    }

    emit(AuthLoading());
    try {
      final user = await _registerUseCase(
        RegisterParams(email: event.email, password: event.password),
      );
      emit(Authenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } on CacheException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Beklenmeyen bir hata oluştu.'));
    }
  }

  Future<void> _onAuthSignOutRequested(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _signOutUseCase(const NoParams());
      emit(Unauthenticated());
    } catch (e) {
      emit(const AuthError('Çıkış yapılamadı.'));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}

/// BLoC içinde kullanılan dahili event — dışarıdan tetiklenemez.
class _AuthStateChanged extends AuthEvent {
  final UserEntity? user;
  const _AuthStateChanged(this.user);

  @override
  List<Object> get props => user != null ? [user!] : [];
}


