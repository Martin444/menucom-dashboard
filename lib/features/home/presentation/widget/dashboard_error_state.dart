import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class DashboardErrorState extends StatelessWidget {
  final String title;
  final String description;
  final String buttonTitle;
  final VoidCallback? onRetry;
  final bool isCompact;

  const DashboardErrorState({
    super.key,
    this.title = 'No pudimos cargar tu información',
    this.description =
        'Parece que hubo un problema de conexión. Verificá tu internet y probá de nuevo.',
    this.buttonTitle = 'Reintentar',
    this.onRetry,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompact(context);
    }
    return _buildFullScreen(context);
  }

  Widget _buildFullScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: PuStyleContainers.borderBottomContainer,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            FluentIcons.cloud_off_24_regular,
            size: 48,
            color: Color(0xFFDC2626),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: PuTextStyle.title1.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: PuTextStyle.description1.copyWith(
            color: const Color(0xFF64748B),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (onRetry != null)
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            child: ButtonPrimary(
              title: buttonTitle,
              onPressed: onRetry!,
              load: false,
            ),
          ),
      ],
    );
  }
}
