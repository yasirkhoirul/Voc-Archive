enum RouteName {
  //general
  signIn("/sign-in"),
  signUp("/sign-up"),
  splash("/splash"),
  //user
  home("/"),
  about("/about"),
  contact("/contact"),
  profile("/profile"),
  settings("/settings"),
  //admin
  adminproductssetting("/products-setting");

  const RouteName(this.path);
  final String path;
}