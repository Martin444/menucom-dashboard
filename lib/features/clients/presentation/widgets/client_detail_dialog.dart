import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:menu_dart_api/by_feature/user/get_users_by_roles/model/user_by_role_model.dart';

class ClientDetailDialog extends StatelessWidget {
  final UserByRoleModel client;

  const ClientDetailDialog({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: PUColors.glassShadow,
      shape: RoundedRectangleBorder(borderRadius: PUBorderRadius.xl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const Divider(height: 1, color: PUColors.borderInputColor),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de contacto',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: PUColors.textColorMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        FluentIcons.mail_24_regular, 'Email', client.email),
                    _buildInfoRow(
                        FluentIcons.phone_24_regular, 'Teléfono', client.phone),
                    _buildInfoRow(FluentIcons.contact_card_24_regular, 'Rol',
                        client.role),
                    const SizedBox(height: 20),
                    const Text(
                      'Detalles de cuenta',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: PUColors.textColorMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(FluentIcons.calendar_ltr_24_regular,
                        'Miembro desde', _formatDate(client.createAt)),
                    _buildInfoRow(FluentIcons.shield_checkmark_24_regular,
                        'Email verificado',
                        client.isEmailVerified == true ? 'Sí' : 'No'),
                    _buildInfoRow(FluentIcons.premium_24_regular, 'Membresía',
                        client.membership?['plan']?.toString() ?? 'Sin plan'),
                    if (client.membership?['plan'] != null) ...[
                      _buildInfoRow(FluentIcons.clock_24_regular,
                          'Próximo cobro', _formatDate(client.lastLoginAt)),
                    ],
                    if (client.storeURL != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(FluentIcons.link_24_regular, 'Catálogo',
                          client.storeURL),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, color: PUColors.borderInputColor),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonSecundary(
                      load: false,
                      title: 'Cerrar',
                      onPressed: () => Get.back(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: PUColors.primaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          UserAvatarAtom(
            size: 56,
            imageUrl: client.photoURL,
            backgroundColor: PUColors.primaryBlueLight,
            iconColor: PUColors.primaryBlue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name ?? 'Sin nombre',
                  style: PuTextStyle.title3,
                ),
                const SizedBox(height: 4),
                Text(
                  client.role?.toUpperCase() ?? 'CLIENTE',
                  style: PuTextStyle.bodySmall.copyWith(
                    color: PUColors.textColorLight,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (client.isEmailVerified == true)
            const Tooltip(
              message: 'Verificado',
              child: Icon(
                FluentIcons.checkmark_circle_24_filled,
                color: PUColors.primaryBlue,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: PUColors.textColorMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: PuTextStyle.bodySmall.copyWith(
              color: PUColors.textColorMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '-',
              style: PuTextStyle.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: PUColors.textColorRich,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
