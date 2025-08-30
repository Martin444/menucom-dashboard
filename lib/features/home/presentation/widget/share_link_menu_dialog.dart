import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickmeup_dashboard/widgets/button_logo.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../../../../core/config.dart';

class ShareLinkMenuDialog extends StatefulWidget {
  final String idMenu;
  const ShareLinkMenuDialog({
    super.key,
    required this.idMenu,
  });

  @override
  State<ShareLinkMenuDialog> createState() => _ShareLinkMenuDialogState();
}

class _ShareLinkMenuDialogState extends State<ShareLinkMenuDialog> {
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool showWhatsappInput = false;
  bool showEmailInput = false;
  bool isDownloading = false;

  String? whatsappErrorText;
  String? emailErrorText;

  String get menuUrl => '$URL_MENU_ORIGIN/${widget.idMenu}';

  void _launchWhatsApp(String phoneNumber) async {
    final trimmedNumber = phoneNumber.trim();
    final RegExp argentinaPhoneRegex = RegExp(r'^549\d{10}$');

    setState(() {
      whatsappErrorText = null;
    });

    if (trimmedNumber.isEmpty) {
      setState(() {
        whatsappErrorText = 'Por favor ingresa un número de teléfono';
      });
      return;
    }

    if (!argentinaPhoneRegex.hasMatch(trimmedNumber)) {
      setState(() {
        whatsappErrorText = 'Número inválido. Usa el formato: 549XXXXXXXXXX, sin el 15';
      });
      return;
    }

    final url = 'https://wa.me/$trimmedNumber?text=${Uri.encodeComponent(menuUrl)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      setState(() {
        whatsappErrorText = 'No se pudo abrir WhatsApp';
      });
    }
  }

  void _launchGmailComposer(String email) async {
    final trimmedEmail = email.trim();
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    setState(() {
      emailErrorText = null;
    });

    if (trimmedEmail.isEmpty) {
      setState(() {
        emailErrorText = 'Por favor ingresa un correo electrónico';
      });
      return;
    }

    if (!emailRegex.hasMatch(trimmedEmail)) {
      setState(() {
        emailErrorText = 'Correo inválido. Usa un formato válido como ejemplo@dominio.com';
      });
      return;
    }

    final url = 'mailto:$trimmedEmail?subject=${Uri.encodeComponent('Menú')}&body=${Uri.encodeComponent(menuUrl)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      setState(() {
        emailErrorText = 'No se pudo abrir Gmail';
      });
    }
  }

  void _downloadQRCode() async {
    if (isDownloading) return;

    setState(() {
      isDownloading = true;
    });

    try {
      // Use QR API service to generate QR code image
      final qrApiUrl =
          'https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=${Uri.encodeComponent(menuUrl)}&format=png&bgcolor=FFFFFF&color=000000&margin=20';

      // Create an image element to load the QR code
      final img = html.ImageElement();
      img.crossOrigin = 'anonymous';

      img.onLoad.listen((_) {
        try {
          // Create canvas
          final canvas = html.CanvasElement(width: 400, height: 400);
          final ctx = canvas.context2D;

          // Draw white background
          ctx.fillStyle = 'white';
          ctx.fillRect(0, 0, 400, 400);

          // Draw the QR image
          ctx.drawImage(img, 0, 0);

          // Convert canvas to blob and download
          canvas.toBlob().then((blob) {
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor = html.AnchorElement(href: url)
              ..setAttribute('download', 'menucom_qr_${widget.idMenu}.png')
              ..style.display = 'none';

            html.document.body?.append(anchor);
            anchor.click();
            anchor.remove();

            html.Url.revokeObjectUrl(url);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QR descargado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }).catchError((error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al procesar la imagen del QR'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al procesar el QR: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });

      img.onError.listen((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cargar la imagen del QR'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });

      // Load the QR image
      img.src = qrApiUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar el QR: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        color: PUColors.bgHeader,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enviar enlace del menú', style: PuTextStyle.title3),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: QrImageView(
                  data: menuUrl,
                  version: QrVersions.auto,
                  semanticsLabel: menuUrl,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: menuUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Se copió la URL correctamente')),
                  );
                },
                icon: const Icon(FluentIcons.copy_24_regular, size: 18),
                label: const Text('Copiar enlace'),
                style: TextButton.styleFrom(
                  foregroundColor: PUColors.bgButton,
                  textStyle: PuTextStyle.brandHeadStyle.copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                LogoButton(
                  icon: FluentIcons.chat_24_regular,
                  colorBackground: PUColors.bgSucces.withOpacity(0.3),
                  iconColor: Colors.green,
                  onTap: () {
                    setState(() {
                      showEmailInput = false;
                      showWhatsappInput = true;
                    });
                  },
                ),
                const SizedBox(width: 10),
                LogoButton(
                  icon: FluentIcons.mail_24_regular,
                  colorBackground: PUColors.bgError.withOpacity(0.3),
                  iconColor: Colors.red,
                  onTap: () {
                    setState(() {
                      showWhatsappInput = false;
                      showEmailInput = true;
                    });
                  },
                ),
                const SizedBox(width: 10),
                LogoButton(
                  icon: FluentIcons.arrow_download_24_regular,
                  colorBackground: isDownloading ? Colors.grey.withOpacity(0.3) : Colors.transparent,
                  iconColor: isDownloading ? Colors.grey : null,
                  onTap: isDownloading
                      ? null
                      : () async {
                          _downloadQRCode();
                        },
                ),
              ],
            ),
            if (isDownloading)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Descargando...'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (showWhatsappInput)
              Column(
                children: [
                  PUInput(
                    hintText: 'Número de WhatsApp (sin +)',
                    controller: whatsappController,
                    textInputType: TextInputType.phone,
                    errorText: whatsappErrorText,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ButtonPrimary(
                      onPressed: () => _launchWhatsApp(whatsappController.text.trim()),
                      title: 'Enviar WhatsApp',
                      load: false,
                    ),
                  ),
                ],
              ),
            if (showEmailInput)
              Column(
                children: [
                  PUInput(
                    hintText: 'Correo electrónico del destinatario',
                    controller: emailController,
                    textInputType: TextInputType.emailAddress,
                    errorText: emailErrorText,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ButtonPrimary(
                      onPressed: () => _launchGmailComposer(emailController.text.trim()),
                      title: 'Enviar email',
                      load: false,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
