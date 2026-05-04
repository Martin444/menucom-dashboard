import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import '../atoms/share_action_button.dart';
import '../molecules/share_input_section.dart';

class ShareOptionsSection extends StatelessWidget {
  final bool showWhatsappInput;
  final bool showEmailInput;
  final bool isDownloading;
  final TextEditingController whatsappController;
  final TextEditingController emailController;
  final String? whatsappErrorText;
  final String? emailErrorText;
  final VoidCallback onToggleWhatsapp;
  final VoidCallback onToggleEmail;
  final VoidCallback onDownload;
  final VoidCallback onWhatsappSend;
  final VoidCallback onEmailSend;

  const ShareOptionsSection({
    super.key,
    required this.showWhatsappInput,
    required this.showEmailInput,
    required this.isDownloading,
    required this.whatsappController,
    required this.emailController,
    this.whatsappErrorText,
    this.emailErrorText,
    required this.onToggleWhatsapp,
    required this.onToggleEmail,
    required this.onDownload,
    required this.onWhatsappSend,
    required this.onEmailSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Share Options Title
        Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtomText(
                'COMPARTIR POR',
                style: PuTextStyle.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Action Buttons Row
        Row(
          children: [
            ShareActionButton(
              icon: FluentIcons.chat_24_filled,
              label: 'WhatsApp',
              color: PUColors.bgSuccess,
              onTap: onToggleWhatsapp,
              isActive: showWhatsappInput,
            ),
            const SizedBox(width: 12),
            ShareActionButton(
              icon: FluentIcons.mail_24_filled,
              label: 'Email',
              color: PUColors.bgError,
              onTap: onToggleEmail,
              isActive: showEmailInput,
            ),
            const SizedBox(width: 12),
            ShareActionButton(
              icon: FluentIcons.arrow_download_24_filled,
              label: 'Descargar',
              color: PUColors.bgButton,
              isLoading: isDownloading,
              onTap: isDownloading ? null : onDownload,
            ),
          ],
        ),

        // Inputs Section
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: (showWhatsappInput || showEmailInput)
              ? Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ShareInputSection(
                    showWhatsappInput: showWhatsappInput,
                    showEmailInput: showEmailInput,
                    whatsappController: whatsappController,
                    emailController: emailController,
                    whatsappErrorText: whatsappErrorText,
                    emailErrorText: emailErrorText,
                    onWhatsappSend: onWhatsappSend,
                    onEmailSend: onEmailSend,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
