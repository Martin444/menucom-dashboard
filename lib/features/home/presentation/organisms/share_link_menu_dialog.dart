import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config.dart';
import '../molecules/share_header.dart';
import './share_qr_card.dart';
import './share_options_section.dart';

class ShareLinkMenuDialog extends StatefulWidget {
  final String idMenu;
  final String? accountEmail;
  const ShareLinkMenuDialog({
    super.key,
    required this.idMenu,
    this.accountEmail,
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

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: menuUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const IconAtom(
              icon: FluentIcons.checkmark_24_filled,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AtomText(
                'Enlace copiado al portapapeles',
                style: PuTextStyle.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: PUColors.bgSuccess,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

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
        whatsappErrorText =
            'Número inválido. Usa el formato: 549XXXXXXXXXX, sin el 15';
      });
      return;
    }

    final url =
        'https://wa.me/$trimmedNumber?text=${Uri.encodeComponent(menuUrl)}';
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
        emailErrorText =
            'Correo inválido. Usa un formato válido como ejemplo@dominio.com';
      });
      return;
    }

    final url =
        'mailto:$trimmedEmail?subject=${Uri.encodeComponent('Menú')}&body=${Uri.encodeComponent(menuUrl)}';
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
      final qrApiUrl =
          'https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=${Uri.encodeComponent(menuUrl)}&format=png&bgcolor=FFFFFF&color=000000&margin=20';

      final img = html.ImageElement();
      img.crossOrigin = 'anonymous';

      img.onLoad.listen((_) {
        try {
          final canvas = html.CanvasElement(width: 400, height: 400);
          final ctx = canvas.context2D;

          ctx.fillStyle = 'white';
          ctx.fillRect(0, 0, 400, 400);
          ctx.drawImage(img, 0, 0);

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
                SnackBar(
                  content: Row(
                    children: [
                      const IconAtom(
                        icon: FluentIcons.checkmark_24_filled,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: AtomText(
                          'QR descargado correctamente',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: PUColors.bgSuccess,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
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
            SnackBar(
              content: Row(
                children: [
                  const IconAtom(
                    icon: FluentIcons.error_circle_24_filled,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: AtomText(
                      'Error al cargar la imagen del QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: PUColors.bgError,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      });

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
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ContainerAtom(
        width: 440,
        variant: ContainerVariant.spacious,
        backgroundColor: PUColors.secundaryBackground,
        borderRadius: BorderRadius.circular(32),
        borderColor: Colors.white.withValues(alpha: 0.08),
        borderWidth: 1.5,
        padding: EdgeInsets.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ShareHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  children: [
                    ShareQRCard(
                      menuUrl: menuUrl,
                      onCopy: _copyToClipboard,
                    ),
                    const SizedBox(height: 32),
                    ShareOptionsSection(
                      showWhatsappInput: showWhatsappInput,
                      showEmailInput: showEmailInput,
                      isDownloading: isDownloading,
                      whatsappController: whatsappController,
                      emailController: emailController,
                      whatsappErrorText: whatsappErrorText,
                      emailErrorText: emailErrorText,
                      onToggleWhatsapp: () => setState(() {
                        showEmailInput = false;
                        showWhatsappInput = !showWhatsappInput;
                      }),
                      onToggleEmail: () => setState(() {
                        showWhatsappInput = false;
                        showEmailInput = !showEmailInput;
                      }),
                      onDownload: _downloadQRCode,
                      onWhatsappSend: () =>
                          _launchWhatsApp(whatsappController.text),
                      onEmailSend: () =>
                          _launchGmailComposer(emailController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
