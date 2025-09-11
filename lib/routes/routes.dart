// ignore_for_file: non_constant_identifier_names

class PURoutes {
  static String HOME = '/';

  //Auth
  static String LOGIN = '/login';
  static String REGISTER_COMMERCE = '/registrate';
  static String CHANGE_PASSWORD = '/change-password';

  //User
  static String USER_PROFILE = '/perfil/:idUsuario';
  static String EDIT_PROFILE = '/editar-perfil';

  //menu
  static String REGISTER_MENU_CATEGORY = '/nuevo-menu';
  static String REGISTER_ITEM_MENU = '/create-menu-item';
  static String EDIT_MENU_CATEGORY = '/edita-tu-menu';
  static String EDIT_ITEM_MENU = '/edit-menu-item';

  //wardrobe
  static String REGISTER_WARDROBES = '/nuevo-guardarropas';
  static String EDIT_WARDROBES = '/edita-tu-guardarropas';
  static String REGISTER_ITEM_WARDROBES = '/nueva-prenda';
  static String EDIT_ITEM_WARDROBES = '/editar-prenda';

  static String REGISTER_PURCHACE = '/registrar-venta';

  static String ORDERS_PAGES = '/ordenes';

  // Business type selection
  static String BUSINESS_TYPE_SELECTION = '/seleccionar-tipo-negocio';

  // Payment methods
  static String PAYMENT_METHODS = '/metodos-de-pago';

  // OAuth Mercado Pago
  static String MP_OAUTH_CALLBACK = '/oauth/callback';
}
