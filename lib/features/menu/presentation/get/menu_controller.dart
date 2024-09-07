import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/models/menu_model.dart';
import 'package:pickmeup_dashboard/features/menu/data/params/menu_params.dart';
import 'package:pickmeup_dashboard/features/menu/data/usecase/delete_menu_usecase.dart';
import 'package:pickmeup_dashboard/features/menu/data/usecase/post_menu_usecase.dart';
import 'package:pickmeup_dashboard/features/menu/data/usecase/put_menu_usecase.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

import '../../../../core/handles/global_handle_dialogs.dart';

class MenusController extends GetxController {
  TextEditingController nameMenu = TextEditingController();
  MenuModel menuSelected = MenuModel();

  bool isLoadMenus = false;

  Future<void> postNewMenu() async {
    try {
      isLoadMenus = true;
      update();
      var responseMenu = await PostMenuUsecase.execute(MenuParams(
        description: nameMenu.text,
      ));

      isLoadMenus = false;
      update();
      return responseMenu;
    } catch (e) {
      isLoadMenus = false;
      update();
      rethrow;
    }
  }

  void gotoEditMenu(MenuModel select) {
    menuSelected = select;
    nameMenu.text = menuSelected.description!;
    update();
    Get.toNamed(PURoutes.EDIT_MENU_CATEGORY);
  }

  Future<dynamic> editMenu() async {
    try {
      isLoadMenus = true;
      update();
      final response = await PutMenuUsecase.execute(
        MenuParams(
          id: menuSelected.id,
          description: nameMenu.text,
        ),
      );
      isLoadMenus = false;
      update();
      return response;
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo editar ${menuSelected.description}, vuelve a intentarlo mas tarde.',
      );
    }
  }

  Future<dynamic> deleteMenus(MenuModel select) async {
    try {
      var isComfirm = await GlobalDialogsHandles.dialogConfirm(
        title: '¿Seguro desea eliminar este menú?',
        message: 'Todos los platos cargados en él se eliminarán',
      );

      if (isComfirm) {
        isLoadMenus = true;
        update();
        await DeleteMenuUsecase.execute(
          MenuParams(
            id: select.id,
            description: nameMenu.text,
          ),
        );
        GlobalDialogsHandles.snackbarSuccess(
          title: '¡Perfecto!',
          message: 'Se eliminó ${select.description} con éxito.',
        );
        isLoadMenus = false;
        update();
      }
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo eliminar ${select.description}, vuelve a intentarlo mas tarde.',
      );
    }
  }
}
