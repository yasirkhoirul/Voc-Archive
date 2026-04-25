enum RouteName {
  //general
  signIn("/sign-in"),
  signUp("/signup"),
  splash("/splash"),
  //user
  home("/"),
  discount("/discount"),
  about("/about"),
  soldout("/soldout"),
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
  adminsoldout("/adminsoldout"),
  adminsliders("/adminsliders"),
  admindisplays("/admindisplays"),
  adminhistory("/adminhistory"),
  adminbrands("/adminbrands"),
  adminaboutus("/adminaboutus");

  const RouteName(this.path);
  final String path;
}
