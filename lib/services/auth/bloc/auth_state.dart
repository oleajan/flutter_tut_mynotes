import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_tut_mynotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateloading extends AuthState {
  const AuthStateloading();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;

  const AuthStateLoggedIn(this.user);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoginFailure extends AuthState {
  final Exception exception;

  const AuthStateLoginFailure(this.exception);
}

class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

class AuthStateLogoutFailure extends AuthState {
  final Exception exception;

  const AuthStateLogoutFailure(this.exception);
}