class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final String role;

  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.role = 'user',
  });
}
