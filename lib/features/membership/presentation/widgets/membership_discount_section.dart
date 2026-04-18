import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pickmeup_dashboard/features/membership/getx/membership_controller.dart';
import 'package:pu_material/pu_material.dart';

class MembershipDiscountSection extends StatefulWidget {
  const MembershipDiscountSection({super.key});

  @override
  State<MembershipDiscountSection> createState() =>
      _MembershipDiscountSectionState();
}

class _MembershipDiscountSectionState extends State<MembershipDiscountSection> {
  final _discountTextController = TextEditingController();

  @override
  void dispose() {
    _discountTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<MembershipController>(
      builder: (controller) {
        final hasDiscount = controller.hasDiscount.value;
        final discountCode = controller.discountCode.value;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PUColors.bgItem,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: PUColors.borderInputColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    FluentIcons.tag_24_regular,
                    color: Color(0xFF7C3AED), // UI/UX Primary
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Código de Descuento',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Fira Code',
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (hasDiscount && discountCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PUColors.bgSucces.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: PUColors.bgSucces.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FluentIcons.checkmark_circle_24_filled,
                        color: PUColors.bgSucces,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Código aplicado: $discountCode',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Fira Sans',
                              ),
                            ),
                            if (controller.discountPercentage.value != null)
                              Text(
                                '${controller.discountPercentage.value}% de descuento mes a mes',
                                style: TextStyle(
                                  color: PUColors.bgSucces,
                                  fontSize: 14,
                                  fontFamily: 'Fira Sans',
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.discountCode.value = null;
                          controller.discountPercentage.value = null;
                          controller.hasDiscount.value = false;
                        },
                        icon: Icon(
                          FluentIcons.dismiss_24_regular,
                          color: PUColors.bgError,
                          size: 24,
                        ),
                        tooltip: 'Quitar descuento',
                      ),
                    ],
                  ),
                )
              ] else ...[
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: PUColors.bgInput,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: PUColors.borderInputColor
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            controller: _discountTextController,
                            decoration: InputDecoration(
                              hintText: 'Ingresa código de descuento',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color:
                                    PUColors.textColor1.withValues(alpha: 0.7),
                                fontFamily: 'Fira Sans',
                              ),
                            ),
                            onSubmitted: (code) =>
                                _applyDiscount(context, controller, code),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _applyDiscount(
                        context,
                        controller,
                        _discountTextController.text,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF7C3AED), // UI/UX Primary
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyDiscount(
      BuildContext context, MembershipController controller, String code) async {
    if (code.isEmpty) return;
    final success = await controller.applyDiscount(code);
    if (context.mounted) {
      if (success) {
        _discountTextController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Descuento aplicado correctamente!'),
            backgroundColor: PUColors.bgSucces,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'Código de descuento inválido'),
            backgroundColor: PUColors.bgError,
          ),
        );
        controller.clearError();
      }
    }
  }
}
