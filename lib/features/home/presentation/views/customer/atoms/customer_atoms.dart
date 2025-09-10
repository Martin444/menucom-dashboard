import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// ÁTOMOS - Componentes básicos e indivisibles

/// Átomo: Avatar circular con icono
class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({
    super.key,
    required this.size,
    this.icon = FluentIcons.person_24_regular,
  });

  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: PUColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: PUColors.primaryColor,
      ),
    );
  }
}

/// Átomo: Texto de título principal
class CustomerTitle extends StatelessWidget {
  const CustomerTitle({
    super.key,
    required this.text,
    this.fontSize = 20,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: PuTextStyle.title2.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: PUColors.textColor1,
      ),
    );
  }
}

/// Átomo: Texto de subtítulo
class CustomerSubtitle extends StatelessWidget {
  const CustomerSubtitle({
    super.key,
    required this.text,
    this.fontSize = 16,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: PuTextStyle.description1.copyWith(
        fontSize: fontSize,
        color: PUColors.textColor3,
      ),
    );
  }
}

/// Átomo: Texto de sección
class CustomerSectionTitle extends StatelessWidget {
  const CustomerSectionTitle({
    super.key,
    required this.text,
    this.fontSize = 18,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: PuTextStyle.title3.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: PUColors.textColor1,
      ),
    );
  }
}

/// Átomo: Icono con color primario
class CustomerIcon extends StatelessWidget {
  const CustomerIcon({
    super.key,
    required this.icon,
    this.size = 20,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: PUColors.primaryColor,
    );
  }
}

/// Átomo: Contenedor base con bordes redondeados
class CustomerContainer extends StatelessWidget {
  const CustomerContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: PUColors.bgItem,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PUColors.borderInputColor.withOpacity(0.2),
        ),
      ),
      child: child,
    );
  }
}
