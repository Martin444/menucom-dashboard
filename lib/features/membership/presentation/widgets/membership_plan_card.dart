import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';

class MembershipPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isCurrentPlan;
  final VoidCallback onSubscribe;

  const MembershipPlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final name = plan['name']?.toString() ?? '';
    final displayName = plan['displayName']?.toString() ?? name;
    final price = (plan['price'] as num?)?.toDouble() ?? 0.0;
    final description = plan['description']?.toString();
    final features = plan['features'] as List? ?? [];
    
    // Design system color logic based on plan tiers
    final bool isEnterprise = name.toUpperCase() == 'ENTERPRISE';
    final Color accentColor = isEnterprise
        ? PUColors.enterpriseAccent
        : (plan['accentColor'] as Color? ?? PUColors.accentColor); // Gold default
    
    final Color buttonColor = isEnterprise ? Colors.black : PUColors.ctaSuccess; // Green CTA

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCurrentPlan
            ? accentColor.withValues(alpha: 0.05)
            : PUColors.bgItem,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentPlan ? accentColor : PUColors.borderInputColor.withValues(alpha: 0.3),
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: isCurrentPlan
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Fira Sans',
                    fontWeight: FontWeight.bold,
                    color: isCurrentPlan ? accentColor : PUColors.textColor3,
                  ),
                ),
              ),
              if (isCurrentPlan)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Actual',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Fira Sans',
                color: PUColors.textColor1,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            price == 0 ? 'Gratis' : '\$${price.toStringAsFixed(2)}/mes',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Fira Sans',
              fontWeight: FontWeight.bold,
              color: isCurrentPlan ? accentColor : PUColors.textColor3,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.map<Widget>((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            FluentIcons.checkmark_12_regular,
                            size: 12,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Fira Sans',
                              color: PUColors.textColor3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!isCurrentPlan)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: price == 0 ? PUColors.iconColor : buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: price == 0 ? 0 : 2,
                ),
                child: Text(
                  price == 0 ? 'Comenzar Free' : 'Hacer Upgrade',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
