import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_users_by_roles/model/user_by_role_model.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';


/// Diálogo de detalle de usuario.
/// Refactorizado: eliminados _buildHeader, _buildSectionTitle, _buildInfoRow, _buildStatusRow.
class UserDetailDialog extends StatelessWidget {
  final UserByRoleModel user;
  final VoidCallback? onAssignMembership;
  final VoidCallback? onBilling;

  const UserDetailDialog({
    super.key,
    required this.user,
    this.onAssignMembership,
    this.onBilling,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: PUColors.glassShadow,
      shape: RoundedRectangleBorder(borderRadius: PUBorderRadius.xl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header — usa DialogHeaderAtom con avatar personalizado
              const UserDetailHeader(),

              const Divider(height: 1, color: PUColors.borderInputColor),

              // Contact info
              Padding(
                padding: PUSpacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitleLabel(text: 'Información de Contacto'),
                    const SizedBox(height: PUTokens.md),
                    InfoRowItem(
                      icon: FluentIcons.mail_24_regular,
                      label: 'Email',
                      value: user.email ?? '-',
                      isVerified: user.isEmailVerified == true,
                    ),
                    InfoRowItem(
                      icon: FluentIcons.phone_24_regular,
                      label: 'Teléfono',
                      value: user.phone ?? '-',
                    ),
                    const SizedBox(height: PUTokens.lg),

                    const SectionTitleLabel(text: 'Detalles de Cuenta'),
                    const SizedBox(height: PUTokens.md),
                    InfoRowItem(
                      icon: FluentIcons.contact_card_24_regular,
                      label: 'Rol',
                      value: user.role ?? '-',
                    ),
                    StatusRowItem(
                      icon: FluentIcons.premium_24_regular,
                      label: 'Membresía',
                      value: user.membership?['plan']?.toString() ??
                          'Sin membresía',
                      statusColor: user.membership?['plan'] != null
                          ? PuBadgeColor.success
                          : PuBadgeColor.neutral,
                    ),
                    InfoRowItem(
                      icon: FluentIcons.calendar_ltr_24_regular,
                      label: 'Miembro desde',
                      value:
                          user.createAt?.toString().split(' ')[0] ?? '-',
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: PUColors.borderInputColor),

              // Actions
              Padding(
                padding: PUSpacing.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonSecundary(
                      load: false,
                      title: 'Cerrar',
                      onPressed: () => Get.back(),
                    ),
                    const Spacer(),
                    ButtonSecundary(
                      load: false,
                      title: 'Asignar Membresía',
                      onPressed: () {
                        Get.back();
                        onAssignMembership?.call();
                      },
                    ),
                    const SizedBox(width: PUTokens.sm),
                    ButtonPrimary(
                      load: false,
                      title: 'Facturación',
                      onPressed: () {
                        final membershipId =
                            user.membership?['id']?.toString();
                        if (membershipId != null &&
                            membershipId.isNotEmpty) {
                          Get.back();
                          onBilling?.call();
                        } else {
                          Get.snackbar(
                            'Sin Membresía',
                            'El usuario no tiene una membresía activa.',
                            backgroundColor: Colors.white,
                            colorText: PUColors.textColorRich,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      },
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

/// Header del diálogo con avatar del usuario.
/// Extraído de _buildHeader.
class UserDetailHeader extends StatelessWidget {
  const UserDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibimos el user a través del ancestro UserDetailDialog
    final dialog =
        context.findAncestorWidgetOfExactType<UserDetailDialog>();
    final user = dialog?.user;

    return Container(
      padding: PUSpacing.lg,
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
            size: 64,
            imageUrl: user?.photoURL,
            backgroundColor: PUColors.primaryBlueLight,
            iconColor: PUColors.primaryBlue,
          ),
          const SizedBox(width: PUTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleAtom(
                  text: user?.name ?? 'Usuario',
                  level: TitleLevel.h3,
                ),
                Text(
                  user?.role?.toUpperCase() ?? 'CLIENTE',
                  style: PuTextStyle.bodySmall.copyWith(
                    color: PUColors.textColorLight,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (user?.isEmailVerified == true)
            const Tooltip(
              message: 'Usuario Verificado',
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
}

/// Etiqueta de sección. Extraído de _buildSectionTitle.
class SectionTitleLabel extends StatelessWidget {
  final String text;

  const SectionTitleLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: PuTextStyle.bodySmall.copyWith(
        color: PUColors.textColorLight,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Fila de información con icono. Extraído de _buildInfoRow.
class InfoRowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isVerified;

  const InfoRowItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PUColors.textColorLight),
          const SizedBox(width: PUTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PuTextStyle.bodySmall.copyWith(
                    color: PUColors.textColorLight,
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: PuTextStyle.bodyMedium.copyWith(
                          color: PUColors.textColorRich,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        FluentIcons.checkmark_circle_16_filled,
                        color: PUColors.successColor,
                        size: 14,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila con badge de estado. Extraído de _buildStatusRow.
class StatusRowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final PuBadgeColor statusColor;

  const StatusRowItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PUColors.textColorLight),
          const SizedBox(width: PUTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PuTextStyle.bodySmall.copyWith(
                    color: PUColors.textColorLight,
                  ),
                ),
                const SizedBox(height: 4),
                PuBadge(
                  label: value,
                  color: statusColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}