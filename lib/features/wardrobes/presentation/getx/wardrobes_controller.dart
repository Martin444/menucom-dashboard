import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/params/post_ward_params.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/delete_wardrobe_usecase.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/post_wardrobe_usecase.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/put_wardrobe_usecase.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/wardrobe_model.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class WardrobesController extends GetxController {
  bool isLoadWard = false;
  TextEditingController nameWard = TextEditingController();

  Future<void> postWardrobe() async {
    try {
      isLoadWard = true;
      update();
      final response = await PostWardrobeUsecase.execute(
        PostWardParams(
          description: nameWard.text,
        ),
      );
      print(response);
      isLoadWard = false;
      update();
    } catch (e) {
      throw e;
    }
  }

  WardrobeModel wardSelected = WardrobeModel(
    id: '',
    idOwner: '',
    items: [],
  );

  void gotoEditWardrobe(WardrobeModel select) {
    wardSelected = select;
    nameWard.text = wardSelected.description!;
    update();
    Get.toNamed(PURoutes.EDIT_WARDROBES);
  }

  void editWardrobe() async {
    try {
      isLoadWard = true;
      update();
      final response = await PutWardrobeUsecase.execute(
        PostWardParams(
          id: wardSelected.id,
          description: nameWard.text,
        ),
      );
      print(response);
      isLoadWard = false;
      update();
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> deleteWardrobe(WardrobeModel select) async {
    try {
      var isComfirm = await GlobalDialogsHandles.dialogConfirm(
        title: '¿Seguro desea eliminar el guardarropas?',
        message: 'Todos los productos cargados en él se eliminarán',
      );

      if (isComfirm) {
        isLoadWard = true;
        update();
        await DeleteWardrobeUsecase.execute(
          PostWardParams(
            id: select.id,
            description: nameWard.text,
          ),
        );
        GlobalDialogsHandles.snackbarSuccess(
          title: '¡Perfecto!',
          message: 'Se eliminó ${select.description} con éxito.',
        );
        isLoadWard = false;
        update();
      }
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo eliminar ${select.description}, vuelve a intentarlo mas tarde.',
      );
      throw e;
    }
  }
}
