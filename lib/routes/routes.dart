// ignore_for_file: non_constant_identifier_names

class PURoutes {
  static String HOME = '/';

  //Auth
  static String LOGIN = '/login';
  static String REGISTER_COMMERCE = '/registrate';
  static String CHANGE_PASSWORD = '/change-password';

  //User
  static String USER_PROFILE = '/perfil/:idUsuario';

  //menu
  static String REGISTER_MENU_CATEGORY = '/nuevo-menu';
  static String REGISTER_ITEM_MENU = '/create-menu-item';
  static String EDIT_MENU_CATEGORY = '/edita-tu-menu';

  //TODO: Falta editar item del menu

  //wardrobe
  static String REGISTER_WARDROBES = '/nuevo-guardarropas';
  static String EDIT_WARDROBES = '/edita-tu-guardarropas';
  static String REGISTER_ITEM_WARDROBES = '/nueva-prenda';

  static String REGISTER_PURCHACE = '/registrar-venta';
}
