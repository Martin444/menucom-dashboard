import 'package:flutter/material.dart';

/// Acciones del banner (Botón de vincular).
class MPBannerActions extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onLink;

  const MPBannerActions({
    super.key,
    required this.isMobile,
    required this.onLink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isMobile)
          Expanded(
            child: _LinkButton(onLink: onLink),
          )
        else ...[
          const Spacer(),
          SizedBox(
            width: 240,
            child: _LinkButton(onLink: onLink),
          ),
        ],
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  final VoidCallback onLink;
  const _LinkButton({required this.onLink});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onLink,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF009EE3),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Vincular ahora',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.arrow_forward_rounded, size: 20),
        ],
      ),
    );
  }
}
