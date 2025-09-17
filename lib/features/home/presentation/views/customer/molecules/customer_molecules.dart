import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_model.dart';

/// MOLÉCULAS - Wrappers de compatibilidad para migración gradual a pu_material
///
/// Estos componentes usan internamente las nuevas molecules de pu_material
/// y mantienen la API existente para evitar breaking changes.

/// Molécula: Tile de información con icono
/// @deprecated Use InfoTileMolecule from pu_material instead
class CustomerInfoTile extends StatelessWidget {
  const CustomerInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InfoTileMolecule(
      icon: icon,
      title: title,
      subtitle: subtitle,
    );
  }
}

/// Molécula: Card de comercio mejorada con datos reales de la API
/// @deprecated Consider using BusinessCardMolecule from pu_material for new implementations
class CommerceCard extends StatelessWidget {
  const CommerceCard({
    super.key,
    required this.name,
    required this.category,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    this.email,
    this.phone,
    this.isEmailVerified,
    this.memberSince,
    this.lastActivity,
    this.menus,
    this.storeUrl,
    this.onTap,
  });

  final String name;
  final String category;
  final double rating;
  final String distance;
  final String imageUrl;
  final String? email;
  final String? phone;
  final bool? isEmailVerified;
  final DateTime? memberSince;
  final DateTime? lastActivity;
  final List<MenuModel>? menus; // Lista de menús del comercio
  final String? storeUrl; // URL de la tienda para visitar
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

        if (isMobile) {
          return _buildMobileCard(context);
        } else if (isTablet) {
          return _buildTabletCard(context);
        } else {
          return _buildDesktopCard(context);
        }
      },
    );
  }

  /// Mobile-optimized card layout
  Widget _buildMobileCard(BuildContext context) {
    return BusinessCardMolecule(
      name: name,
      category: category,
      imageUrl: imageUrl,
      isVerified: isEmailVerified ?? false,
      contactInfo: _buildContactInfo(),
      additionalInfo: _buildAdditionalInfo(),
      badges: _buildBadges(),
      actions: _buildMobileActions(),
      storeURL: storeUrl,
      onStoreUrlTap: _launchStoreUrl,
      onTap: onTap ?? _launchStoreUrl,
    );
  }

  /// Tablet-optimized card layout
  Widget _buildTabletCard(BuildContext context) {
    return BusinessCardMolecule(
      name: name,
      category: category,
      imageUrl: imageUrl,
      isVerified: isEmailVerified ?? false,
      contactInfo: _buildContactInfo(),
      additionalInfo: _buildAdditionalInfo(),
      badges: _buildBadges(),
      actions: _buildActions(),
      storeURL: storeUrl,
      onStoreUrlTap: _launchStoreUrl,
      onTap: onTap ?? _launchStoreUrl,
    );
  }

  /// Desktop card layout (original)
  Widget _buildDesktopCard(BuildContext context) {
    return BusinessCardMolecule(
      name: name,
      category: category,
      imageUrl: imageUrl,
      isVerified: isEmailVerified ?? false,
      contactInfo: _buildContactInfo(),
      additionalInfo: _buildAdditionalInfo(),
      badges: _buildBadges(),
      actions: _buildActions(),
      storeURL: storeUrl,
      onStoreUrlTap: _launchStoreUrl,
      onTap: onTap ?? _launchStoreUrl,
    );
  }

  /// Mobile-optimized actions with priority order
  List<BusinessCardAction> _buildMobileActions() {
    List<BusinessCardAction> actionList = [];

    // Priority 1: Phone call (most important for mobile)
    if (phone != null && phone!.trim().isNotEmpty) {
      actionList.add(BusinessCardAction(
        label: 'Llamar',
        icon: FluentIcons.phone_24_regular,
        onPressed: () => _launchPhoneCall(phone!),
        backgroundColor: Colors.blue,
      ));
    }

    // Priority 2: Visit store (secondary) - shorter label for mobile
    if (storeUrl != null && storeUrl!.trim().isNotEmpty) {
      actionList.add(BusinessCardAction(
        label: 'Web',
        icon: FluentIcons.globe_24_regular,
        onPressed: _launchStoreUrl,
        backgroundColor: Colors.green,
      ));
    }

    return actionList;
  }

  List<ContactInfo> _buildContactInfo() {
    List<ContactInfo> contactList = [];

    // if (email != null && email!.trim().isNotEmpty && email!.contains('@')) {
    //   contactList.add(ContactInfo(
    //     icon: FluentIcons.mail_24_regular,
    //     value: _maskEmail(email!),
    //   ));
    // }

    if (phone != null && phone!.trim().isNotEmpty) {
      contactList.add(ContactInfo(
        icon: FluentIcons.phone_24_regular,
        value: _formatPhoneNumber(phone!),
      ));
    }

    return contactList;
  }

  List<AdditionalInfo> _buildAdditionalInfo() {
    List<AdditionalInfo> infoList = [];

    // Información de membresía
    if (memberSince != null) {
      infoList.add(AdditionalInfo(
        text: _formatMemberSince(memberSince!),
        icon: FluentIcons.calendar_24_regular,
        color: PUColors.primaryColor,
      ));
    }

    // Estado de actividad
    if (lastActivity != null) {
      final isRecent = _isRecentActivity(lastActivity!);
      infoList.add(AdditionalInfo(
        text: _formatLastActivity(lastActivity!),
        icon: FluentIcons.presence_available_24_regular,
        color: isRecent ? Colors.green[700] : PUColors.textColor3,
      ));
    }

    // Información de productos/menús
    if (menus != null && menus!.isNotEmpty) {
      final totalItems = _getTotalMenuItems();
      final avgDeliveryTime = _getAverageDeliveryTime();

      if (totalItems > 0) {
        infoList.add(AdditionalInfo(
          text: '$totalItems productos disponibles',
          icon: FluentIcons.food_24_regular,
          color: Colors.orange[600],
        ));
      }

      if (avgDeliveryTime > 0) {
        infoList.add(AdditionalInfo(
          text: 'Entrega promedio: ${avgDeliveryTime}min',
          icon: FluentIcons.clock_24_regular,
          color: Colors.blue[600],
        ));
      }
    }

    return infoList;
  }

  List<BadgeInfo> _buildBadges() {
    List<BadgeInfo> badgeList = [];

    if (menus != null && menus!.isNotEmpty) {
      final totalItems = _getTotalMenuItems();
      if (totalItems > 0) {
        // Badge de productos con mejor diseño
        badgeList.add(BadgeInfo(
          text: '$totalItems platos',
          backgroundColor: Colors.green.withOpacity(0.15),
          borderColor: Colors.green.withOpacity(0.4),
          textColor: Colors.green[700]!,
        ));
      }

      // Badge de tiempo de entrega si está disponible
      final avgDeliveryTime = _getAverageDeliveryTime();
      if (avgDeliveryTime > 0) {
        String deliveryText;
        Color badgeColor;

        if (avgDeliveryTime <= 30) {
          deliveryText = 'Entrega rápida';
          badgeColor = Colors.green;
        } else if (avgDeliveryTime <= 60) {
          deliveryText = 'Entrega normal';
          badgeColor = Colors.orange;
        } else {
          deliveryText = 'Entrega lenta';
          badgeColor = Colors.red;
        }

        badgeList.add(BadgeInfo(
          text: deliveryText,
          backgroundColor: badgeColor.withOpacity(0.15),
          borderColor: badgeColor.withOpacity(0.4),
          textColor: badgeColor,
        ));
      }
    }

    // Badge de verificación si aplica
    if (isEmailVerified == true) {
      badgeList.add(BadgeInfo(
        text: '✓ Verificado',
        backgroundColor: Colors.blue.withOpacity(0.15),
        borderColor: Colors.blue.withOpacity(0.4),
        textColor: Colors.blue,
      ));
    }

    return badgeList;
  }

  List<BusinessCardAction> _buildActions() {
    List<BusinessCardAction> actionList = [];

    // Acción principal: Ver menú (si tiene productos)
    if (menus != null && menus!.isNotEmpty && _getTotalMenuItems() > 0) {
      actionList.add(BusinessCardAction(
        label: 'Ver Menú',
        icon: FluentIcons.food_24_regular,
        onPressed: () {
          // Navegar al menú del comercio
          debugPrint('Ver menú de $name');
        },
        backgroundColor: PUColors.primaryColor,
      ));
    }

    // Acción de tienda web (si tiene URL)
    if (storeUrl != null && storeUrl!.trim().isNotEmpty) {
      actionList.add(BusinessCardAction(
        label: 'Tienda Web',
        icon: FluentIcons.globe_24_regular,
        onPressed: _launchStoreUrl,
        backgroundColor: Colors.green,
      ));
    }

    // Acción de contacto (si tiene teléfono)
    if (phone != null && phone!.trim().isNotEmpty) {
      actionList.add(BusinessCardAction(
        label: 'Llamar',
        icon: FluentIcons.phone_24_regular,
        onPressed: () => _launchPhoneCall(phone!),
        backgroundColor: Colors.blue,
      ));
    }

    return actionList;
  }

  // Helper methods (mantienen la funcionalidad original)
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return email;

    final maskedUsername = username.substring(0, 2) + '*' * (username.length - 2);

    return '$maskedUsername@$domain';
  }

  String _formatMemberSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return 'Nuevo';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}m';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}a';
    }
  }

  String _formatLastActivity(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Activo ahora';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return 'Inactivo';
    }
  }

  bool _isRecentActivity(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inHours < 24; // Consideramos reciente si fue en las últimas 24h
  }

  String _formatPhoneNumber(String phone) {
    // Remover todos los caracteres no numéricos
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.isEmpty) return phone;

    // Formatear según la longitud del número
    if (cleanPhone.length == 10) {
      // Formato: (XXX) XXX-XXXX
      return '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 11 && cleanPhone.startsWith('1')) {
      // Formato: +1 (XXX) XXX-XXXX
      return '+1 (${cleanPhone.substring(1, 4)}) ${cleanPhone.substring(4, 7)}-${cleanPhone.substring(7)}';
    } else if (cleanPhone.length >= 8) {
      // Para números internacionales o de otra longitud, formatear con espacios
      if (cleanPhone.length > 10) {
        return '+${cleanPhone.substring(0, cleanPhone.length - 10)} ${cleanPhone.substring(cleanPhone.length - 10, cleanPhone.length - 7)}-${cleanPhone.substring(cleanPhone.length - 7, cleanPhone.length - 4)}-${cleanPhone.substring(cleanPhone.length - 4)}';
      } else {
        return '${cleanPhone.substring(0, cleanPhone.length - 4)}-${cleanPhone.substring(cleanPhone.length - 4)}';
      }
    }

    return phone; // Retornar original si no se puede formatear
  }

  int _getTotalMenuItems() {
    if (menus == null || menus!.isEmpty) {
      debugPrint('CommerceCard: No menus data for $name');
      return 0;
    }

    int total = 0;
    for (final menu in menus!) {
      if (menu.items != null) {
        total += menu.items!.length;
        debugPrint('CommerceCard: Menu "${menu.description}" has ${menu.items!.length} items');
      }
    }
    debugPrint('CommerceCard: Total items for $name: $total');
    return total;
  }

  int _getAverageDeliveryTime() {
    if (menus == null || menus!.isEmpty) {
      debugPrint('CommerceCard: No menus for delivery time calculation');
      return 0;
    }

    int totalTime = 0;
    int itemCount = 0;

    for (final menu in menus!) {
      if (menu.items != null) {
        for (final item in menu.items!) {
          if (item.deliveryTime != null) {
            totalTime += item.deliveryTime!;
            itemCount++;
            debugPrint('CommerceCard: Item "${item.name}" delivery time: ${item.deliveryTime}min');
          }
        }
      }
    }

    final avgTime = itemCount > 0 ? (totalTime / itemCount).round() : 0;
    debugPrint('CommerceCard: Average delivery time for $name: ${avgTime}min (from $itemCount items)');
    return avgTime;
  }

  Future<void> _launchStoreUrl() async {
    if (storeUrl == null || storeUrl!.trim().isEmpty) {
      debugPrint('CommerceCard: No store URL provided');
      return;
    }

    try {
      // Validar que la URL tenga un esquema válido
      String urlToLaunch = storeUrl!.trim();
      if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }

      final Uri url = Uri.parse(urlToLaunch);

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Abrir en navegador externo
        );
      } else {
        debugPrint('CommerceCard: Cannot launch URL: $urlToLaunch');
      }
    } catch (e) {
      debugPrint('CommerceCard: Error launching URL: $e');
    }
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      debugPrint('CommerceCard: No phone number provided');
      return;
    }

    try {
      // Limpiar el número de teléfono y preparar la URL tel:
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      if (!cleanPhone.startsWith('+')) {
        // Si no empieza con +, asumir que es un número local
        // Agregar código de país por defecto si es necesario
        if (cleanPhone.length == 10) {
          cleanPhone = '+1$cleanPhone'; // Asumir EE.UU. para números de 10 dígitos
        }
      }

      final Uri telUri = Uri.parse('tel:$cleanPhone');

      if (await canLaunchUrl(telUri)) {
        await launchUrl(
          telUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('CommerceCard: Cannot launch phone call to: $cleanPhone');
      }
    } catch (e) {
      debugPrint('CommerceCard: Error launching phone call: $e');
    }
  }
}

/// Molécula: Header de bienvenida del usuario
/// @deprecated Use WelcomeHeaderMolecule from pu_material instead
class CustomerWelcomeHeader extends StatelessWidget {
  const CustomerWelcomeHeader({
    super.key,
    required this.userName,
    required this.isMobile,
  });

  final String userName;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return WelcomeHeaderMolecule(
      userName: userName,
      description: 'Bienvenido a tu panel de cliente',
      isCompact: isMobile,
    );
  }
}

/// Molécula: Notificación simple
/// @deprecated Use NotificationMolecule from pu_material instead
class CustomerNotification extends StatelessWidget {
  const CustomerNotification({
    super.key,
    required this.message,
    this.icon = FluentIcons.info_24_regular,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return NotificationMolecule(
      message: message,
      icon: icon,
      type: NotificationType.info,
    );
  }
}
