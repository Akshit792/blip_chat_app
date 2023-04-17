abstract class AuthenticationState {}

class InitialAuthenticationState extends AuthenticationState {}

class LoadingAuthenticationState extends AuthenticationState {}

class LoadedAuthenticationState extends AuthenticationState {}

class ErrorAuthenticationState extends AuthenticationState {}
