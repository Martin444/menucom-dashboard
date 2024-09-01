import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/head_actions.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/wardrobes/presentation/getx/wardrobes_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:svg_flutter/svg.dart';

import '../widget/head_dinning.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var dinninController = Get.find<DinningController>();

  @override
  void initState() {
    dinninController.getMyDinningInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = Get.width < 700;
    return GetBuilder<DinningController>(
      builder: (dinning) {
        if (dinning.isLoaginDataUser) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: PUColors.primaryBackground,
            drawerScrimColor: Colors.transparent,
            body: Row(
              children: [
                const MenuSIde(),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Header
                          const HeadDinning(),

                          const HeadActions(),

                          // Seccion de items del menú
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              child: Row(
                                children: [
                                  // items
                                  dinning.wardList.isNotEmpty
                                      ? Flexible(
                                          child: WardsHomeView(isMobile: isMobile),
                                        )
                                      : Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    PUImages.noDataImageSvg,
                                                    height: 140,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      'Registrá tus prendas en guardarropas flexibles',
                                                      textAlign: TextAlign.center,
                                                      style: PuTextStyle.title5,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 70,
                                                  ),
                                                  SizedBox(
                                                    width: 300,
                                                    child: ButtonPrimary(
                                                      title: 'Comenzar',
                                                      onPressed: () {
                                                        Get.toNamed(PURoutes.REGISTER_WARDROBES);
                                                      },
                                                      load: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WardsHomeView extends StatefulWidget {
  const WardsHomeView({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  State<WardsHomeView> createState() => _WardsHomeViewState();
}

class _WardsHomeViewState extends State<WardsHomeView> {
  var wardController = Get.find<WardrobesController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return LayoutBuilder(
          builder: (context, constrains) {
            return SizedBox(
              height: constrains.maxHeight,
              child: Row(
                children: [
                  Flexible(
                    flex: 8,
                    child: Container(
                      padding: const EdgeInsets.only(
                        right: 20,
                      ),
                      child: GridView.builder(
                        itemCount: 5,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widget.isMobile ? 2 : 4,
                          // mainAxisExtent: 300,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 20,
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.red,
                          );
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      height: constrains.maxHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: PuStyleContainers.borderLeftContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mis guardarropas',
                            style: PuTextStyle.title1,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ..._.wardList.map(
                            (element) {
                              return ItemCategoryTile(
                                item: element,
                                descriptionBuilder: (ward) {
                                  return ward.description!;
                                },
                                onDelete: (ward) {},
                                onEdit: (ward) {
                                  wardController.gotoEditWardrobe(ward);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
