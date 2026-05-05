import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';

class ShareInputSection extends StatelessWidget {
  final bool showWhatsappInput;
  final bool showEmailInput;
  final TextEditingController whatsappController;
  final TextEditingController emailController;
  final String? whatsappErrorText;
  final String? emailErrorText;
  final VoidCallback onWhatsappSend;
  final VoidCallback onEmailSend;

  const ShareInputSection({
    super.key,
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
          ContainerAtom(
            variant: ContainerVariant.minimal,
            backgroundColor: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            borderColor: Colors.white.withOpacity(0.1),
            borderWidth: 1,
            padding: EdgeInsets.zero,
            child: PUInput(
              hintText: 'Número de WhatsApp (ej: 5491122334455)',
              controller: whatsappController,
              textInputType: TextInputType.phone,
              errorText: whatsappErrorText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
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
          ContainerAtom(
            variant: ContainerVariant.minimal,
            backgroundColor: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            borderColor: Colors.white.withOpacity(0.1),
            borderWidth: 1,
            padding: EdgeInsets.zero,
            child: PUInput(
              hintText: 'Correo electrónico',
              controller: emailController,
              textInputType: TextInputType.emailAddress,
              errorText: emailErrorText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
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
