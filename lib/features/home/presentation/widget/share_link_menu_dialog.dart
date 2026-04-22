import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:pu_material/pu_material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config.dart';

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
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PUColors.bgHeader.withValues(alpha: 0.95),
              PUColors.bgHeader.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PUColors.bgButton.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: PUColors.bgSucces.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FluentIcons.checkmark_circle_24_filled,
                      color: PUColors.bgSucces,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¡Todo Listo!',
                    style: PuTextStyle.title2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Compartí tu menú con tus clientes',
                    style: PuTextStyle.brandHeadStyle.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  if (widget.accountEmail != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FluentIcons.wallet_24_filled,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.accountEmail!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        QrImageView(
                          data: menuUrl,
                          version: QrVersions.auto,
                          semanticsLabel: menuUrl,
                          size: 180.0,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF1E293B),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  menuUrl,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    color: Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: menuUrl));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(
                                            FluentIcons.checkmark_24_filled,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Enlace copiado'),
                                        ],
                                      ),
                                      backgroundColor: PUColors.bgSucces,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: PUColors.bgButton,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    FluentIcons.copy_24_filled,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ShareButton(
                        icon: FluentIcons.chat_24_filled,
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        onTap: () {
                          setState(() {
                            showEmailInput = false;
                            showWhatsappInput = !showWhatsappInput;
                          });
                        },
                        isActive: showWhatsappInput,
                      ),
                      const SizedBox(width: 12),
                      _ShareButton(
                        icon: FluentIcons.mail_24_filled,
                        label: 'Email',
                        color: const Color(0xFFEA4335),
                        onTap: () {
                          setState(() {
                            showWhatsappInput = false;
                            showEmailInput = !showEmailInput;
                          });
                        },
                        isActive: showEmailInput,
                      ),
                      const SizedBox(width: 12),
                      _ShareButton(
                        icon: FluentIcons.arrow_download_24_filled,
                        label: 'QR',
                        color: PUColors.bgButton,
                        isLoading: isDownloading,
                        onTap: isDownloading
                            ? null
                            : () async {
                                _downloadQRCode();
                              },
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _ShareInputSection(
                        showWhatsappInput: showWhatsappInput,
                        showEmailInput: showEmailInput,
                        whatsappController: whatsappController,
                        emailController: emailController,
                        whatsappErrorText: whatsappErrorText,
                        emailErrorText: emailErrorText,
                        onWhatsappSend: () => _launchWhatsApp(whatsappController.text.trim()),
                        onEmailSend: () => _launchGmailComposer(emailController.text.trim()),
                      ),
                    ),
                    crossFadeState: showWhatsappInput || showEmailInput
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareInputSection extends StatelessWidget {
  final bool showWhatsappInput;
  final bool showEmailInput;
  final TextEditingController whatsappController;
  final TextEditingController emailController;
  final String? whatsappErrorText;
  final String? emailErrorText;
  final VoidCallback onWhatsappSend;
  final VoidCallback onEmailSend;

  const _ShareInputSection({
    required this.showWhatsappInput,
    required this.showEmailInput,
    required this.whatsappController,
    required this.emailController,
    this.whatsappErrorText,
    this.emailErrorText,
    required this.onWhatsappSend,
    required this.onEmailSend,
  });

  @override
  Widget build(BuildContext context) {
    if (showWhatsappInput) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: PUInput(
              hintText: 'Número de WhatsApp (sin +)',
              controller: whatsappController,
              textInputType: TextInputType.phone,
              errorText: whatsappErrorText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ButtonPrimary(
              onPressed: onWhatsappSend,
              title: 'Enviar por WhatsApp',
              load: false,
              icon: FluentIcons.send_24_filled,
            ),
          ),
        ],
      );
    }

    if (showEmailInput) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: PUInput(
              hintText: 'Correo electrónico del destinatario',
              controller: emailController,
              textInputType: TextInputType.emailAddress,
              errorText: emailErrorText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ButtonPrimary(
              onPressed: onEmailSend,
              title: 'Enviar por Email',
              load: false,
              icon: FluentIcons.send_24_filled,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isLoading;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isActive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.white.withValues(alpha: 0.15),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(
                icon,
                color: isActive ? color : Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? color : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
