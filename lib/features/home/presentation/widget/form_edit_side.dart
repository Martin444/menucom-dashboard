import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';
import 'package:pu_material/widgets/inputs/pu_input.dart';

class FormEditSide extends StatelessWidget {
  const FormEditSide({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        var isMobile = Get.width < 700;
        return Container(
          margin: EdgeInsets.only(left: !isMobile ? 20 : 0),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: PUColors.bgItem.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Visibility(
                    visible: isMobile,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back_ios,
                            ),
                            Text(
                              'Volver',
                              style: PuTextStyle.description1,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Editar plato del menú',
                    style: PuTextStyle.title3,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Image.network(
                    _.photoController,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  PUInput(
                    labelText: 'Nombre del plato',
                    controller: _.nameController,
                  ),
                  PUInput(
                    labelText: 'Precio',
                    controller: _.priceController,
                  ),
                  PUInput(
                    labelText: 'Tiempo de preparación (en minutos)',
                    controller: _.deliveryController,
                  ),
                ],
              ),
              Column(
                children: [
                  ButtonPrimary(
                    title: 'Guardar cambios',
                    onPressed: () {
                      _.editItemMenu();
                    },
                    load: _.isEditProcess,
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
