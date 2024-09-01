import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/widgets/menu/items/itemdraw.dart';

import '../controllers/dinning_controller.dart';

class MenuSIde extends StatelessWidget {
  const MenuSIde({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return Drawer(
          backgroundColor: PUColors.bgItem.withOpacity(0.3),
          elevation: 0,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 60,
              sigmaY: 60,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: const Color(0xFFBCBCBC),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Image.network(
                        _.dinningLogin.photoURL!,
                        height: 100,
                        scale: 0.2,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconHomeMenu,
                        label: 'Inicio',
                        isSelected: true,
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconOrderMenu,
                        label: 'Ordenes',
                        isSelected: false,
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconSalesMenu,
                        label: 'Ventas',
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconClientsMenu,
                        label: 'Clientes',
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconProveeMenu,
                        label: 'Proveedores',
                        onRoute: () {},
                      ),
                    ],
                  ),
                  ItemDrawMenu(
                    icon: PUIcons.iconExitMenu,
                    label: 'Cerrar sesión',
                    onRoute: () {
                      _.closeSesion();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
