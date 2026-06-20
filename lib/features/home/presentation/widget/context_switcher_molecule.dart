import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class ContextSwitcherMolecule extends StatefulWidget {
  final bool compact;
  const ContextSwitcherMolecule({super.key, this.compact = false});

  @override
  State<ContextSwitcherMolecule> createState() => _ContextSwitcherMoleculeState();

  static Future<void> switchContext(CommerceContext context) async {
    try {
      final response = await SwitchContextUseCase().execute(
        SwitchContextRequest(commerceId: context.id),
      );

      API.setAccessToken(response.accessToken);

      try {
        final dinning = Get.find<DinningController>();
        dinning.dinningLogin.commerceId = response.commerceId;
        dinning.dinningLogin.businessName = context.businessName;
        dinning.dinningLogin.slug = context.slug;
        dinning.getMyDinningInfo();
      } catch (_) {}

      Get.back();
      Get.offAllNamed('/');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cambiar de negocio: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static void editCurrentBusiness() {
    Get.toNamed(PURoutes.BUSINESS_PROFILE);
  }

  static void createNewCommerce() {
    Get.back();
    Get.toNamed(PURoutes.CREATE_COMMERCE);
  }

  static Future<void> showSelectionDialog({
    bool barrierDismissible = true,
  }) {
    final ctx = Get.context!;
    return showDialog(
      context: ctx,
      barrierDismissible: barrierDismissible,
      builder: (_) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: PUBorderRadius.lg,
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: const _CommerceSelectionTitle(),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const SizedBox(
            width: double.maxFinite,
            child: CommerceSelectionContent(showClose: true),
          ),
        ),
      ),
    );
  }
}

class _ContextSwitcherMoleculeState extends State<ContextSwitcherMolecule> {
  void _showContextDialog() {
    ContextSwitcherMolecule.showSelectionDialog();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showContextDialog,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 8 : 12,
            vertical: widget.compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: PUColors.primaryBlueLight.withValues(alpha: 0.5),
            borderRadius: PUBorderRadius.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FluentIcons.store_microsoft_24_regular,
                size: 16,
                color: PUColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: GetBuilder<DinningController>(
                  builder: (_) {
                    return Text(
                      _.dinningLogin.businessName ?? 'Seleccionar negocio',
                      style: PuTextStyle.bodySmall.copyWith(
                        color: PUColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                FluentIcons.chevron_down_24_regular,
                size: 14,
                color: PUColors.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommerceSelectionTitle extends StatelessWidget {
  const _CommerceSelectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          FluentIcons.store_microsoft_24_regular,
          color: PUColors.primaryBlue,
          size: 24,
        ),
        SizedBox(width: 12),
        Text(
          'Mis negocios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class CommerceSelectionContent extends StatefulWidget {
  final bool showClose;

  const CommerceSelectionContent({super.key, this.showClose = false});

  @override
  State<CommerceSelectionContent> createState() => _CommerceSelectionContentState();
}

class _CommerceSelectionContentState extends State<CommerceSelectionContent> {
  var _loading = true;
  var _contexts = <CommerceContext>[];
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContexts());
  }

  Future<void> _loadContexts() async {
    if (_loaded) return;
    _loaded = true;
    try {
      _contexts = await GetMyContextsUseCase().execute();
    } catch (e) {
      debugPrint('Error loading contexts: $e');
    } finally {
      _loading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final activeContext = _contexts.firstWhereOrNull((c) => c.isCurrent);
    final otherContexts = _contexts.where((c) => !c.isCurrent).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ACTIVE COMMERCE
        if (activeContext != null) ...[
          const Text(
            'Comercio actual',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PUColors.textColorMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          _CommerceCard(
            context: activeContext,
            isActive: true,
            onTap: () => ContextSwitcherMolecule.switchContext(activeContext),
            onEdit: () => ContextSwitcherMolecule.editCurrentBusiness(),
          ),
        ],

        // OTHER COMMERCES (o todos si no hay activo)
        if (otherContexts.isNotEmpty) ...[
          SizedBox(height: activeContext != null ? 24 : 0),
          Text(
            activeContext != null ? 'Cambiar a otro comercio' : 'Selecciona un comercio',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PUColors.textColorMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          ...otherContexts.map((ctxItem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CommerceCard(
                context: ctxItem,
                isActive: false,
                onTap: () => ContextSwitcherMolecule.switchContext(ctxItem),
              ),
            );
          }),
        ],

        // CREAR NUEVO NEGOCIO
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: PUBorderRadius.lg,
            onTap: () => ContextSwitcherMolecule.createNewCommerce(),
            child: Container(
              decoration: BoxDecoration(
                color: PUColors.primaryBlueLight.withValues(alpha: 0.3),
                borderRadius: PUBorderRadius.lg,
                border: Border.all(
                  color: PUColors.primaryBlue.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PUColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FluentIcons.add_24_regular,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Crear nuevo negocio',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: PUColors.primaryBlue,
                      ),
                    ),
                  ),
                  const Icon(
                    FluentIcons.arrow_right_24_regular,
                    color: PUColors.primaryBlue,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommerceCard extends StatelessWidget {
  final CommerceContext context;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _CommerceCard({
    required this.context,
    required this.isActive,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: PUBorderRadius.lg,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? PUColors.primaryBlueLight.withValues(alpha: 0.4)
                : PUColors.bgInput,
            border: isActive
                ? Border.all(
                    color: PUColors.primaryBlue.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
            borderRadius: PUBorderRadius.lg,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: isActive ? 44 : 40,
                height: isActive ? 44 : 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? PUColors.primaryBlue.withValues(alpha: 0.15)
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: !isActive
                      ? Border.all(color: PUColors.bgInput, width: 1)
                      : null,
                ),
                child: Icon(
                  isActive
                      ? FluentIcons.store_microsoft_24_filled
                      : FluentIcons.store_microsoft_24_regular,
                  color: isActive
                      ? PUColors.primaryBlue
                      : PUColors.textColorMuted,
                  size: isActive ? 22 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      this.context.businessName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isActive ? 15 : 14,
                        color: PUColors.textColorRich,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      this.context.role != null
                          ? '${this.context.slug}  •  ${this.context.role}'
                          : this.context.slug,
                      style: PuTextStyle.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isActive && onEdit != null) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: PUBorderRadius.md,
                    onTap: onEdit,
                    child: const Tooltip(
                      message: 'Editar perfil del negocio',
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          FluentIcons.edit_24_regular,
                          size: 18,
                          color: PUColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PUColors.primaryBlue,
                    borderRadius: PUBorderRadius.full,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FluentIcons.checkmark_12_filled,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Actual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!isActive)
                const Icon(
                  FluentIcons.arrow_right_24_regular,
                  color: PUColors.textColorMuted,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
