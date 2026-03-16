class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.displayName,
  });

  final int id;
  final String username;
  final String avatarUrl;
  final String displayName;
}
