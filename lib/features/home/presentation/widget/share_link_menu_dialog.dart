import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickmeup_dashboard/widgets/button_logo.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config.dart';

class ShareLinkMenuDialog extends StatelessWidget {
  final String idMenu;
  const ShareLinkMenuDialog({
    super.key,
    required this.idMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        color: PUColors.bgHeader,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enviar enlace del menú',
              style: PuTextStyle.title3,
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: QrImageView(
                data: '$URL_MENU_ORIGIN/$idMenu',
                version: QrVersions.auto,
                semanticsLabel: '$URL_MENU_ORIGIN/$idMenu',
                size: 200.0,
              ),
            ),
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LogoButton(
                    pathIcon: PUIcons.iconWhatsapp,
                    colorBackground: PUColors.bgSucces.withOpacity(0.3),
                    onTap: () async {
                      final url =
                          'https://wa.me/${3873413199}?text=${Uri.encodeComponent('Hola este es un mensaje')}';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        print('No se pudo abrir WhatsApp.');
                      }
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  LogoButton(
                    pathIcon: PUIcons.iconGmail,
                    colorBackground: PUColors.bgError.withOpacity(0.3),
                    onTap: () async {
                      final url =
                          'https://mail.google.com/mail/?view=cm&to=alejandrofarel62@gmail.com&su=${Uri.encodeComponent('Adjunto')}&body=${Uri.encodeComponent('Mensaje')}';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        print('No se pudo abrir Gmail.');
                      }
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  LogoButton(
                    pathIcon: PUIcons.iconDownload,
                    colorBackground: Colors.transparent,
                    onTap: () async {
                      final url =
                          'https://mail.google.com/mail/?view=cm&to=alejandrofarel62@gmail.com&su=${Uri.encodeComponent('Adjunto')}&body=${Uri.encodeComponent('Mensaje')}';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        print('No se pudo abrir Gmail.');
                      }
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(
                    text: '$URL_MENU_ORIGIN/$idMenu',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    dismissDirection: DismissDirection.up,
                    content: Text('Se copió la URL correctamente'),
                  ),
                );
              },
              child: AbsorbPointer(
                absorbing: true,
                child: PUInput(
                  labelText: 'Haz click para copiar el enlace',
                  controller: TextEditingController(
                    text: '$URL_MENU_ORIGIN/$idMenu',
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
