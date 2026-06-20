import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:menu_dart_api/by_feature/commerce/models/commerce.dart';
import 'package:pickmeup_dashboard/features/profile/presentation/controllers/business_profile_controller.dart';

class BusinessProfilePage extends StatelessWidget {
  const BusinessProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BusinessProfileController>()) {
      Get.put(BusinessProfileController());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                FluentIcons.arrow_left_24_regular,
                color: Colors.black87,
              ),
              onPressed: () => _handleBack(),
            ),
            title: Text(
              'Editar negocio',
              style: PuTextStyle.title3.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              GetBuilder<BusinessProfileController>(
                builder: (ctrl) {
                  if (!ctrl.hasChanges) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Obx(() {
                      return TextButton(
                        onPressed: ctrl.isSaving.value
                            ? null
                            : ctrl.saveProfile,
                        child: ctrl.isSaving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    PUColors.primaryColor,
                                  ),
                                ),
                              )
                            : Text(
                                'Guardar',
                                style: PuTextStyle.description1.copyWith(
                                  color: PUColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
          body: GetBuilder<BusinessProfileController>(
            builder: (ctrl) {
              return FutureBuilder<Commerce?>(
                future: ctrl.loadFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return PopScope(
                    canPop: !ctrl.hasChanges,
                    onPopInvokedWithResult: (didPop, result) {
                      if (!didPop) {
                        _handleBack();
                      }
                    },
                    child: isMobile
                        ? const _BusinessProfileMobileContent()
                        : const _BusinessProfileDesktopContent(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _handleBack() {
    final ctrl = Get.find<BusinessProfileController>();
    if (ctrl.hasChanges) {
      Get.dialog(
        AlertDialog(
          title: Text(
            'Descartar cambios',
            style: PuTextStyle.title3,
          ),
          content: Text(
            'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir sin guardarlos?',
            style: PuTextStyle.description1,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancelar',
                style: PuTextStyle.description1.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: Text(
                'Descartar',
                style: PuTextStyle.description1.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }
}

class _BusinessProfileMobileContent extends StatelessWidget {
  const _BusinessProfileMobileContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BusinessProfileController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImagesSection(ctrl: ctrl),
          const SizedBox(height: 16),
          _InfoSection(ctrl: ctrl),
          const SizedBox(height: 16),
          _ContactSection(ctrl: ctrl),
          const SizedBox(height: 16),
          _SocialSection(ctrl: ctrl),
          const SizedBox(height: 32),
          _buildMobileActionButtons(ctrl),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMobileActionButtons(BusinessProfileController ctrl) {
    return GetBuilder<BusinessProfileController>(
      builder: (ctrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              return ButtonPrimary(
                title: 'Guardar cambios',
                onPressed: ctrl.hasChanges && !ctrl.isSaving.value
                    ? ctrl.saveProfile
                    : null,
                load: ctrl.isSaving.value,
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              return ButtonSecundary(
                title: 'Cancelar',
                onPressed: ctrl.isSaving.value
                    ? null
                    : () {
                        if (ctrl.hasChanges) {
                          _showDiscardDialog(ctrl);
                        } else {
                          Get.back();
                        }
                      },
                load: false,
              );
            }),
          ],
        );
      },
    );
  }

  void _showDiscardDialog(BusinessProfileController ctrl) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Descartar cambios',
          style: PuTextStyle.title3,
        ),
        content: Text(
          'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir sin guardarlos?',
          style: PuTextStyle.description1,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: PuTextStyle.description1.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text(
              'Descartar',
              style: PuTextStyle.description1.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessProfileDesktopContent extends StatelessWidget {
  const _BusinessProfileDesktopContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BusinessProfileController>();

    return Center(
      child: SizedBox(
        width: 800,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImagesSection(ctrl: ctrl),
              const SizedBox(height: 24),
              _InfoSection(ctrl: ctrl),
              const SizedBox(height: 24),
              _ContactSection(ctrl: ctrl),
              const SizedBox(height: 24),
              _SocialSection(ctrl: ctrl),
              const SizedBox(height: 48),
              _buildDesktopActionButtons(ctrl),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopActionButtons(BusinessProfileController ctrl) {
    return GetBuilder<BusinessProfileController>(
      builder: (ctrl) {
        return Row(
          children: [
            Expanded(
              child: Obx(() {
                return ButtonSecundary(
                  title: 'Cancelar',
                  onPressed: ctrl.isSaving.value
                      ? null
                      : () {
                          if (ctrl.hasChanges) {
                            _showDiscardDialog(ctrl);
                          } else {
                            Get.back();
                          }
                        },
                  load: false,
                );
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() {
                return ButtonPrimary(
                  title: 'Guardar cambios',
                  onPressed: ctrl.hasChanges && !ctrl.isSaving.value
                      ? ctrl.saveProfile
                      : null,
                  load: ctrl.isSaving.value,
                );
              }),
            ),
          ],
        );
      },
    );
  }

  void _showDiscardDialog(BusinessProfileController ctrl) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Descartar cambios',
          style: PuTextStyle.title3,
        ),
        content: Text(
          'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir sin guardarlos?',
          style: PuTextStyle.description1,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: PuTextStyle.description1.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text(
              'Descartar',
              style: PuTextStyle.description1.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconAtom(
          icon: icon,
          size: 20,
          color: PUColors.primaryColor,
        ),
        const SizedBox(width: 8),
        TitleAtom(
          text: title,
          level: TitleLevel.section,
        ),
      ],
    );
  }
}

class _ImagesSection extends StatelessWidget {
  final BusinessProfileController ctrl;
  const _ImagesSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessProfileController>(
      builder: (_) {
        return ContainerAtom(
          variant: ContainerVariant.card,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(
                title: 'Imagenes',
                icon: FluentIcons.image_24_regular,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ImagePicker(
                      ctrl: ctrl,
                      isLogo: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _ImagePicker(
                      ctrl: ctrl,
                      isLogo: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final BusinessProfileController ctrl;
  final bool isLogo;
  const _ImagePicker({required this.ctrl, required this.isLogo});

  @override
  Widget build(BuildContext context) {
    final label = isLogo ? 'Logo' : 'Portada';
    final imageBytes = isLogo ? ctrl.selectedLogoBytes : ctrl.selectedCoverBytes;
    final imageUrl = isLogo ? ctrl.currentLogoUrl : ctrl.currentCoverUrl;
    final onSelect = isLogo ? ctrl.selectLogo : ctrl.selectCover;
    final onRemove = isLogo ? ctrl.removeLogo : ctrl.removeCover;
    final height = isLogo ? 140.0 : 160.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PuTextStyle.bodySmall.copyWith(
            color: PUColors.textColorMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => onSelect(),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: PUColors.bgInput,
              borderRadius: PUBorderRadius.md,
              border: (imageBytes != null || (imageUrl != null && imageUrl.isNotEmpty))
                  ? null
                  : Border.all(
                      color: PUColors.borderInputColor,
                    ),
            ),
            child: _buildContent(label, imageBytes, imageUrl, onRemove),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
      String label, dynamic imageBytes, String? imageUrl, VoidCallback onRemove) {
    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: PUBorderRadius.md,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              imageBytes,
              fit: isLogo ? BoxFit.contain : BoxFit.cover,
            ),
            _buildRemoveButton(onRemove),
          ],
        ),
      );
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: PUBorderRadius.md,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PuRobustNetworkImage(
              imageUrl: imageUrl,
              fit: isLogo ? BoxFit.contain : BoxFit.cover,
            ),
            _buildRemoveButton(onRemove),
          ],
        ),
      );
    }

    return _placeholder(label);
  }

  Widget _buildRemoveButton(VoidCallback onRemove) {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: PUColors.bgError,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            FluentIcons.dismiss_24_regular,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _placeholder(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FluentIcons.camera_add_24_regular,
            size: 32,
            color: PUColors.textColorLight,
          ),
          const SizedBox(height: 8),
          Text(
            'Agregar $label',
            style: PuTextStyle.bodySmall.copyWith(
              color: PUColors.textColorLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca para seleccionar',
            style: PuTextStyle.description2.copyWith(
              color: PUColors.textColorMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final BusinessProfileController ctrl;
  const _InfoSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessProfileController>(
      builder: (_) {
        return ContainerAtom(
          variant: ContainerVariant.card,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(
                title: 'Informacion basica',
                icon: FluentIcons.building_shop_24_regular,
              ),
              const SizedBox(height: 16),
              PUInput(
                controller: ctrl.nameController,
                labelText: 'Nombre del negocio',
                hintText: 'Ej: Mi Restaurante',
              ),
              const SizedBox(height: 12),
              PUInput(
                controller: ctrl.slugController,
                labelText: 'Slug',
                hintText: 'mi-restaurante',
              ),
              const SizedBox(height: 12),
              PUInput(
                controller: ctrl.descriptionController,
                labelText: 'Descripcion',
                hintText: 'Describe tu negocio...',
                maxLines: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactSection extends StatelessWidget {
  final BusinessProfileController ctrl;
  const _ContactSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessProfileController>(
      builder: (_) {
        return ContainerAtom(
          variant: ContainerVariant.card,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(
                title: 'Contacto',
                icon: FluentIcons.call_24_regular,
              ),
              const SizedBox(height: 16),
              PUInput(
                controller: ctrl.phoneController,
                labelText: 'Telefono',
                hintText: 'Ej: +54 11 1234-5678',
                textInputType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              PUInput(
                controller: ctrl.addressController,
                labelText: 'Direccion',
                hintText: 'Ej: Av. Corrientes 1234, CABA',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SocialSection extends StatelessWidget {
  final BusinessProfileController ctrl;
  const _SocialSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessProfileController>(
      builder: (_) {
        return ContainerAtom(
          variant: ContainerVariant.card,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(
                title: 'Redes sociales',
                icon: FluentIcons.people_community_24_regular,
              ),
              const SizedBox(height: 16),
              PUInput(
                controller: ctrl.instagramController,
                labelText: 'Instagram',
                hintText: '@tuusuario',
              ),
              const SizedBox(height: 12),
              PUInput(
                controller: ctrl.facebookController,
                labelText: 'Facebook',
                hintText: 'facebook.com/tuusuario',
              ),
              const SizedBox(height: 12),
              PUInput(
                controller: ctrl.websiteController,
                labelText: 'Sitio web',
                hintText: 'https://tusitio.com',
                textInputType: TextInputType.url,
              ),
            ],
          ),
        );
      },
    );
  }
}
