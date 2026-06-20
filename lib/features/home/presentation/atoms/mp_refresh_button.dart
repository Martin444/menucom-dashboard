import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import '../../controllers/dinning_controller.dart';

/// Botón para refrescar la información del comercio.
class MPRefreshButton extends StatelessWidget {
  final DinningController controller;

  const MPRefreshButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GetX<DinningController>(
        builder: (controller) => controller.isLoadingMPStatus.value
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : IconButton(
                onPressed: () => controller.refreshMPStatus(),
                icon: const Icon(FluentIcons.arrow_sync_24_regular, color: Colors.white),
                tooltip: 'Actualizar estado',
              ),
      ),
    );
  }
}
