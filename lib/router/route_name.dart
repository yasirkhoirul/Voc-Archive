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
  product("/product"),
  productDetail("/product/:id"),
  //admin
  adminproducts("/adminproducts"),
  adminproductssetting("/product/:id");

  const RouteName(this.path);
  final String path;
}