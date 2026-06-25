import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/by_feature/notifications/models/user_with_fcm_token.dart';
import 'package:pu_material/pu_material.dart';
import '../../getx/notifications_controller.dart';

class UserSelector extends StatelessWidget {
  const UserSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Seleccionar destinatarios',
              style: PuTextStyle.title3.copyWith(
                fontSize: PUTokens.fontMd,
                color: PUColors.textColorRich,
              ),
            ),
            const Spacer(),
            Obx(() {
              final count = controller.selectedUserIds.length;
              return Text(
                '$count seleccionados',
                style: PuTextStyle.bodySmall.copyWith(
                  color: count > 0 ? PUColors.accentColor : PUColors.textColorLight,
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: PUTokens.sm),
        TextField(
          onChanged: (value) => controller.searchUsers(value),
          decoration: InputDecoration(
            hintText: 'Buscar usuarios...',
            hintStyle: PuTextStyle.hintTextStyle,
            prefixIcon: const Icon(FluentIcons.search_24_regular, size: 20),
            prefixIconColor: PUColors.iconColor,
            filled: true,
            fillColor: PUColors.bgInput,
            border: OutlineInputBorder(
              borderRadius: PUBorderRadius.md,
              borderSide: const BorderSide(color: PUColors.borderInputColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: PUBorderRadius.md,
              borderSide: const BorderSide(color: PUColors.borderInputColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: PUBorderRadius.md,
              borderSide: const BorderSide(color: PUColors.primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: PuTextStyle.hintTextStyle,
        ),
        const SizedBox(height: PUTokens.sm),
        Obx(() {
          if (controller.usersWithFcm.isNotEmpty) {
            return GestureDetector(
              onTap: () => controller.selectAllUsers(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Obx(() {
                  final allSelected =
                      controller.selectedUserIds.length == controller.usersWithFcm.length;
                  return Row(
                    children: [
                      Icon(
                        allSelected
                            ? FluentIcons.checkbox_checked_24_filled
                            : FluentIcons.checkbox_unchecked_24_regular,
                        size: 18,
                        color: allSelected ? PUColors.accentColor : PUColors.textColorLight,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        allSelected ? 'Deseleccionar todos' : 'Seleccionar todos',
                        style: PuTextStyle.bodySmall.copyWith(
                          color: allSelected ? PUColors.accentColor : PUColors.textColorLight,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: PUTokens.xs),
        Expanded(
          child: Obx(() {
            if (controller.isUsersLoading.value &&
                controller.usersWithFcm.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.usersError.value != null &&
                controller.usersWithFcm.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(controller.usersError.value!,
                        style: const TextStyle(color: PUColors.errorColor)),
                    const SizedBox(height: 8),
                    ButtonPrimary(
                      title: 'Reintentar',
                      load: false,
                      onPressed: () => controller.loadUsers(refresh: true),
                    ),
                  ],
                ),
              );
            }

            if (controller.usersWithFcm.isEmpty) {
              return Center(
                child: Text(
                  'No se encontraron usuarios con FCM',
                  style: PuTextStyle.bodySmall.copyWith(
                    color: PUColors.textColorLight,
                  ),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.usersWithFcm.length,
                    itemBuilder: (context, index) {
                      final user = controller.usersWithFcm[index];
                      return _UserCheckboxTile(user: user);
                    },
                  ),
                ),
                Obx(() {
                  if (controller.usersHasMore.value) {
                    return TextButton(
                      onPressed: () => controller.loadMoreUsers(),
                      child: Text(
                        'Cargar más',
                        style: PuTextStyle.bodySmall.copyWith(
                          color: PUColors.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _UserCheckboxTile extends StatelessWidget {
  final UserWithFcmToken user;

  const _UserCheckboxTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Obx(() {
      final isSelected = controller.selectedUserIds.contains(user.id);
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        dense: true,
        leading: Icon(
          isSelected
              ? FluentIcons.checkbox_checked_24_filled
              : FluentIcons.checkbox_unchecked_24_regular,
          size: 20,
          color: isSelected ? PUColors.accentColor : PUColors.textColorLight,
        ),
        title: Text(
          user.name,
          style: PuTextStyle.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: PUColors.textColorRich,
          ),
        ),
        subtitle: Text(
          user.email,
          style: PuTextStyle.bodySmall.copyWith(
            fontSize: PUTokens.fontXs,
            color: PUColors.textColorLight,
          ),
        ),
        trailing: Icon(
          user.hasFcmToken
              ? FluentIcons.phone_24_regular
              : FluentIcons.phone_dismiss_24_regular,
          size: 16,
          color: user.hasFcmToken ? PUColors.successColor : PUColors.textColorLight,
        ),
        onTap: () => controller.toggleUserSelection(user.id),
        selected: isSelected,
      );
    });
  }
}
