import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

class ShareActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isLoading;

  const ShareActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isActive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InteractiveAtom(
        onTap: onTap,
        child: ContainerAtom(
          variant: ContainerVariant.compact,
          backgroundColor: isActive
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderColor: isActive
              ? color.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          borderWidth: 1.5,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                IconAtom(
                  icon: icon,
                  color: isActive ? color : Colors.white.withValues(alpha: 0.6),
                  size: 24,
                ),
              const SizedBox(height: 8),
              AtomText(
                label,
                style: PuTextStyle.bodySmall.copyWith(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? color : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
