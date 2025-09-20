import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pu_material/pu_material.dart';

class CardTakePhoto extends StatelessWidget {
  final void Function() onTaka;
  final bool? isTaked;
  final String? title;
  final bool? isLogo;
  final Uint8List photoInBytes;
  const CardTakePhoto({
    super.key,
    required this.onTaka,
    required this.photoInBytes,
    this.isTaked,
    this.title,
    this.isLogo,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTaka();
        },
        child: isTaked ?? false
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  photoInBytes,
                  height: 130,
                  width: double.infinity,
                  fit: isLogo ?? false ? BoxFit.contain : BoxFit.cover,
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: PUColors.bgInput,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      FluentIcons.camera_24_regular,
                      color: PUColors.textColor1,
                    ),
                    Text(
                      title ?? 'Cargá tu logo (.jpg, .png)',
                      style: PuTextStyle.textLabelMenu,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
