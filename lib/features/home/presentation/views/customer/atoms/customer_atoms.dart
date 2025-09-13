import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// ÁTOMOS - Wrappers de compatibilidad para migración gradual a pu_material
///
/// Estos componentes están marcados como deprecated y usan internamente
/// los nuevos atoms de pu_material. Se recomienda migrar gradualmente
/// al uso directo de los componentes de pu_material.

/// Átomo: Avatar circular con icono
/// @deprecated Use UserAvatarAtom from pu_material instead
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
    return UserAvatarAtom(
      size: size,
      icon: icon,
    );
  }
}

/// Átomo: Texto de título principal
/// @deprecated Use TitleAtom with level TitleLevel.h2 from pu_material instead
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
    return TitleAtom(
      text: text,
      level: TitleLevel.h2,
    );
  }
}

/// Átomo: Texto de subtítulo
/// @deprecated Use SubtitleAtom with variant SubtitleVariant.description from pu_material instead
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
    return SubtitleAtom(
      text: text,
      variant: SubtitleVariant.description,
      fontSize: fontSize,
    );
  }
}

/// Átomo: Texto de sección
/// @deprecated Use TitleAtom with level TitleLevel.section from pu_material instead
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
    return TitleAtom(
      text: text,
      level: TitleLevel.section,
    );
  }
}

/// Átomo: Icono con color primario
/// @deprecated Use IconAtom from pu_material instead
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
    return IconAtom(
      icon: icon,
      size: size,
    );
  }
}

/// Átomo: Contenedor base con bordes redondeados
/// @deprecated Use ContainerAtom with variant ContainerVariant.card from pu_material instead
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
    return ContainerAtom(
      variant: ContainerVariant.card,
      padding: padding,
      child: child,
    );
  }
}
