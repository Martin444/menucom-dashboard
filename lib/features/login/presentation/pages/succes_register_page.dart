import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:svg_flutter/svg.dart';

class SuccesRegisterPage extends StatefulWidget {
  final String? imageUrl;
  final String? title;
  final String? message;
  final String? postData;

  const SuccesRegisterPage({
    super.key,
    this.imageUrl,
    this.title,
    this.message,
    this.postData,
  });

  @override
  State<SuccesRegisterPage> createState() => _SuccesRegisterPageState();
}

class _SuccesRegisterPageState extends State<SuccesRegisterPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeIn(
                  child: SvgPicture.asset(
                    widget.imageUrl ?? PUImages.succesImageSvg,
                    height: 220,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                FadeInUp(
                  from: 30,
                  child: Text(
                    widget.title ?? '¡Bienvenid@!',
                    style: PuTextStyle.title1,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                FadeInUp(
                  from: 30,
                  child: Text(
                    widget.message ?? 'Ya sos parte del ecosistema Menu com',
                    style: PuTextStyle.description1,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                FadeInUp(
                  from: 30,
                  child: Text(
                    widget.postData ?? 'Tus credenciales son el email y la contraseña que ingresaste anteriormente.',
                    style: PuTextStyle.title3,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                ButtonPrimary(
                  title: 'Continuar',
                  onPressed: () {
                    Get.toNamed(PURoutes.LOGIN);
                  },
                  load: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
