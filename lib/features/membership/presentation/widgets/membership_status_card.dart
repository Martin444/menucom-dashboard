import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pickmeup_dashboard/features/membership/getx/membership_controller.dart';
import 'package:pu_material/pu_material.dart';

class MembershipStatusCard extends StatelessWidget {
  const MembershipStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<MembershipController>(
      builder: (controller) {
        final isActive = controller.isActive.value;
        final plan = controller.currentPlan.value ?? 'FREE';
        final status = controller.subscriptionStatus.value ?? 'inactive';
        final amountVal = controller.amount.value;
        final currency = controller.currency.value;
        final hasDiscount = controller.hasDiscount.value;
        final discountPct = controller.discountPercentage.value;
        final nextBilling = controller.nextBillingDate.value;

        IconData statusIcon;
        switch (status.toLowerCase()) {
          case 'active':
          case 'authorized':
            statusIcon = FluentIcons.checkmark_circle_24_filled;
            break;
          case 'paused':
            statusIcon = FluentIcons.pause_circle_24_regular;
            break;
          case 'pending':
            statusIcon = FluentIcons.clock_24_regular;
            break;
          case 'cancelled':
          case 'canceled':
            statusIcon = FluentIcons.dismiss_circle_24_regular;
            break;
          default:
            statusIcon = FluentIcons.circle_24_regular;
        }

        // Glassmorphism properties - Use design system tokens
        final Color baseColor = isActive ? PUColors.glassPremiumBg : PUColors.iconColor;
        final Color secondaryColor = isActive ? PUColors.premiumAccent.withValues(alpha: 0.65) : Colors.grey.shade400;

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [baseColor.withValues(alpha: 0.85), secondaryColor.withValues(alpha: 0.65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isActive ? PUColors.glassPremiumShadow : PUColors.glassShadow,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Light reflection effect
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.getPlanLabel(plan),
                                  style: PuTextStyle.membershipPlanTitle,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        statusIcon,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        controller.getStatusLabel(status),
                                        style: PuTextStyle.membershipStatus,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            child: Icon(
                              isActive ? FluentIcons.premium_32_regular : FluentIcons.star_32_regular,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (isActive && amountVal > 0) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (hasDiscount && discountPct != null) ...[
                              Text(
                                '$currency ${(amountVal * (1 - discountPct / 100)).toStringAsFixed(2)}',
                                style: PuTextStyle.membershipPriceLarge,
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E), // UI/UX Green CTA
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '-${discountPct.toStringAsFixed(0)}%',
                                  style: PuTextStyle.membershipBadge,
                                ),
                              ),
                            ] else ...[
                              Text(
                                '$currency ${amountVal.toStringAsFixed(2)}',
                                style: PuTextStyle.membershipPriceLarge,
                              ),
                            ],
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '/mes',
                                style: PuTextStyle.membershipPriceLabel,
                              ),
                            ),
                          ],
                        ),
                        if (nextBilling != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                FluentIcons.calendar_24_regular,
                                color: Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Próxima facturación: ${_formatDate(nextBilling)}',
                                style: PuTextStyle.membershipPriceLabel.copyWith(fontSize: 15),
                              ),
                            ],
                          ),
                        ],
                      ],
                      if (!isActive) ...[
                        Text(
                          'Plan Gratis',
                          style: PuTextStyle.membershipPlanTitle.copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Hasta 10 items, 1 catálogo, 7 días analytics',
                          style: PuTextStyle.membershipPlanSubtitle.copyWith(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
