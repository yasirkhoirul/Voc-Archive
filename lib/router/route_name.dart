enum RouteName {
  //general
  signIn("/sign-in"),
  signUp("/sign-up"),
  splash("/splash"),
  //user
  home("/"),
  discount("/discount"),
  about("/about"),
  contact("/contact"),
  profile("/profile"),
  cart("/cart"),
  checkout("/checkout"),
  history("/history"),
  settings("/settings"),
  product("/product"),
  productDetail("/product/:id"),
  //admin
  adminproducts("/adminproducts"),
  adminproductssetting("/adminproducts/:id"),
  adminsliders("/adminsliders"),
  admindisplays("/admindisplays"),
  adminbrands("/adminbrands");

  const RouteName(this.path);
  final String path;
}