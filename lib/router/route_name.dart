enum RouteName {
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