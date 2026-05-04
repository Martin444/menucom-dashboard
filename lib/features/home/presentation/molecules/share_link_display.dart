import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';

class ShareLinkDisplay extends StatelessWidget {
  final String menuUrl;
  final VoidCallback onCopy;

  const ShareLinkDisplay({
    super.key,
    required this.menuUrl,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerAtom(
      variant: ContainerVariant.compact,
      backgroundColor: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const IconAtom(
            icon: FluentIcons.link_24_regular,
            color: Color(0xFF64748B),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AtomText(
              menuUrl,
              style: PuTextStyle.bodySmall.copyWith(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          InteractiveAtom(
            onTap: onCopy,
            child: const IconAtom(
              icon: FluentIcons.copy_24_regular,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
