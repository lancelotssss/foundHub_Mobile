class ActiveUser {
  static Map<String, dynamic> activeUser = {
  };
  static bool get loggedIn => activeUser.isNotEmpty;
}
