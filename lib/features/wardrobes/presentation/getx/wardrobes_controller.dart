import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/params/post_ward_params.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/post_wardrobe_usecase.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/put_wardrobe_usecase.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/wardrobe_model.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class WardrobesController extends GetxController {
  bool isLoadWard = false;
  TextEditingController nameWard = TextEditingController();

  void postWardrobe() async {
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
    update();
    Get.toNamed(PURoutes.EDIT_WARDROBES);
  }

  void editWardrobe() async {
    try {
      isLoadWard = true;
      update();
      final response = await PutWardrobeUsecase.execute(
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
}
