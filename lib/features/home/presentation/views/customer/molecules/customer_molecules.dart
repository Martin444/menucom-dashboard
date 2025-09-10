import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/pu_robust_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_model.dart';
import '../atoms/customer_atoms.dart';

/// MOLÉCULAS - Combinaciones de átomos

/// Molécula: Tile de información con icono
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
    return Row(
      children: [
        CustomerIcon(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: PuTextStyle.nameProductStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  color: PUColors.textColor1,
                ),
              ),
              Text(
                subtitle,
                style: PuTextStyle.brandHeadStyle.copyWith(
                  color: PUColors.textColor3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Molécula: Card de comercio mejorada con datos reales de la API
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Debug temporal para ver qué datos llegan
    debugPrint(
        'CommerceCard: $name - Email: $email, Phone: $phone, Verified: $isEmailVerified, MemberSince: $memberSince, LastActivity: $lastActivity');

    return GestureDetector(
      onTap: onTap,
      child: CustomerContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con imagen y badges de confianza
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del comercio
                _buildCommerceImage(),
                const SizedBox(width: 12),

                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre con badge de verificación
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: PuTextStyle.nameProductStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: PUColors.textColor1,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isEmailVerified == true) ...[
                            const SizedBox(width: 8),
                            _buildVerificationBadge(),
                          ],
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Categoría
                      Text(
                        category,
                        style: PuTextStyle.brandHeadStyle.copyWith(
                          color: PUColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Información de contacto (solo si hay datos válidos)
            if (_hasValidContactInfo()) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: PUColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: PUColors.primaryColor.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                child: _buildContactInfo(),
              ),
              const SizedBox(height: 8),
            ] else ...[
              // Mostrar mensaje si no hay información de contacto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Sin información de contacto',
                  style: TextStyle(
                    fontSize: 10,
                    color: PUColors.textColor3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            // Rating y distancia en una línea simple
            _buildRatingInfo(),

            const SizedBox(height: 4),

            // Información adicional (membresía y actividad)
            _buildAdditionalInfo(),

            // Información de menús si están disponibles
            if (menus != null && menus!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildMenusInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommerceImage() {
    // Debug para ver la URL de imagen
    debugPrint('CommerceCard Image URL: "$imageUrl"');

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PUColors.primaryColor.withOpacity(0.1),
        border: Border.all(
          color: PUColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: imageUrl.isNotEmpty && imageUrl != 'null'
            ? PuRobustNetworkImage(
                imageUrl: imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(PUColors.primaryColor),
                    ),
                  ),
                ),
                errorWidget: _buildDefaultIcon(),
              )
            : _buildDefaultIcon(),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Icon(
      FluentIcons.store_microsoft_24_regular,
      size: 32,
      color: PUColors.primaryColor,
    );
  }

  Widget _buildVerificationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FluentIcons.checkmark_circle_24_filled,
            size: 12,
            color: Colors.green[600],
          ),
          const SizedBox(width: 2),
          Text(
            'Verificado',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Row(
      children: [
        if (email != null && email!.trim().isNotEmpty && email!.contains('@')) ...[
          Icon(
            FluentIcons.mail_24_regular,
            size: 14,
            color: PUColors.primaryColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _maskEmail(email!),
              style: PuTextStyle.brandHeadStyle.copyWith(
                color: PUColors.textColor1, // Cambiado a textColor1 para mejor contraste
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (phone != null && phone!.trim().isNotEmpty) ...[
          if (email != null && email!.trim().isNotEmpty && email!.contains('@')) const SizedBox(width: 12),
          Icon(
            FluentIcons.phone_24_regular,
            size: 14,
            color: PUColors.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            _formatPhoneNumber(phone!),
            style: PuTextStyle.brandHeadStyle.copyWith(
              color: PUColors.textColor1, // Cambiado a textColor1 para mejor contraste
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingInfo() {
    // Debug para verificar rating y distancia
    debugPrint('CommerceCard Rating: $rating, Distance: $distance');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          FluentIcons.star_24_filled,
          size: 16,
          color: Colors.amber[600],
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1), // Mostrar solo 1 decimal
          style: PuTextStyle.brandHeadStyle.copyWith(
            color: PUColors.textColor1,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          FluentIcons.location_24_regular,
          size: 14,
          color: PUColors.textColor3,
        ),
        const SizedBox(width: 4),
        Text(
          distance,
          style: PuTextStyle.brandHeadStyle.copyWith(
            color: PUColors.textColor3,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    List<Widget> infoWidgets = [];

    // Membresía
    if (memberSince != null) {
      final membershipText = _formatMemberSince(memberSince!);
      infoWidgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FluentIcons.calendar_24_regular,
              size: 10,
              color: PUColors.textColor1, // Mejorado para mejor contraste
            ),
            const SizedBox(width: 4),
            Text(
              membershipText,
              style: TextStyle(
                fontSize: 10,
                color: PUColors.textColor1, // Mejorado para mejor contraste
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Actividad
    if (lastActivity != null) {
      final activityText = _formatLastActivity(lastActivity!);
      final isRecent = _isRecentActivity(lastActivity!);

      if (infoWidgets.isNotEmpty) {
        infoWidgets.add(const SizedBox(width: 12));
      }

      infoWidgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FluentIcons.presence_available_24_regular,
              size: 10,
              color: isRecent ? Colors.green[700] : PUColors.textColor1, // Mejorado contraste
            ),
            const SizedBox(width: 4),
            Text(
              activityText,
              style: TextStyle(
                fontSize: 10,
                color: isRecent ? Colors.green[700] : PUColors.textColor1, // Mejorado contraste
                fontWeight: isRecent ? FontWeight.w600 : FontWeight.w500, // Más peso para mejor legibilidad
              ),
            ),
          ],
        ),
      );
    }

    if (infoWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: infoWidgets,
    );
  }

  // Helpers para validar y formatear datos
  bool _hasValidContactInfo() {
    final hasValidEmail = email != null && email!.trim().isNotEmpty && email!.contains('@');
    final hasValidPhone = phone != null && phone!.trim().isNotEmpty;
    return hasValidEmail || hasValidPhone;
  }

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

  /// Formatea el número de teléfono para una mejor presentación visual
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

  /// Construye el widget de información de menús
  Widget _buildMenusInfo() {
    final menusCount = menus?.length ?? 0;
    final totalItems = _getTotalMenuItems();

    if (menusCount == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              FluentIcons.food_24_regular,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              'Sin menús disponibles',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con ícono y contador
          Row(
            children: [
              Icon(
                FluentIcons.food_24_filled,
                size: 14,
                color: Colors.green[600],
              ),
              const SizedBox(width: 6),
              Text(
                'Menús disponibles',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalItems platos',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tags de menús
          _buildMenuTags(),

          // Productos destacados
          if (totalItems > 0) ...[
            const SizedBox(height: 8),
            _buildFeaturedProducts(),
          ],
        ],
      ),
    );
  }

  /// Calcula el total de items en todos los menús
  int _getTotalMenuItems() {
    if (menus == null || menus!.isEmpty) return 0;

    int total = 0;
    for (final menu in menus!) {
      if (menu.items != null) {
        total += menu.items!.length;
      }
    }
    return total;
  }

  /// Construye los tags de nombres de menús
  Widget _buildMenuTags() {
    if (menus == null || menus!.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: menus!.take(3).map((menu) {
        // Mostrar máximo 3 menús
        final menuName = menu.description ?? 'Menú sin nombre';
        final itemsCount = menu.items?.length ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.document_24_regular,
                size: 10,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 3),
              Text(
                menuName,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (itemsCount > 0) ...[
                const SizedBox(width: 3),
                Text(
                  '($itemsCount)',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Construye la vista de productos destacados
  Widget _buildFeaturedProducts() {
    final featuredItems = _getFeaturedItems();

    if (featuredItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de productos
        Row(
          children: [
            Icon(
              FluentIcons.star_24_filled,
              size: 10,
              color: Colors.amber[600],
            ),
            const SizedBox(width: 4),
            Text(
              'Productos destacados',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Lista horizontal de productos que se adapta al contenido
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < featuredItems.take(3).length; i++) ...[
                Expanded(
                  child: _buildProductCard(featuredItems[i]),
                ),
                if (i < featuredItems.take(3).length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Construye una card individual de producto
  Widget _buildProductCard(Map<String, dynamic> item) {
    final name = item['name'] as String? ?? 'Sin nombre';
    final price = item['price'] as int? ?? 0;
    final photoUrl = item['photoURL'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagen del producto
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: photoUrl.isNotEmpty && photoUrl != 'null'
                  ? PuRobustNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 70,
                      placeholder: Center(
                        child: Icon(
                          FluentIcons.food_24_regular,
                          size: 24,
                          color: Colors.grey[400],
                        ),
                      ),
                      errorWidget: Center(
                        child: Icon(
                          FluentIcons.food_24_regular,
                          size: 24,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        FluentIcons.food_24_regular,
                        size: 24,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),

          // Información del producto
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (price > 0)
                  Text(
                    _formatPrice(price),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene una lista de items destacados de todos los menús
  List<Map<String, dynamic>> _getFeaturedItems() {
    if (menus == null || menus!.isEmpty) return [];

    List<Map<String, dynamic>> allItems = [];

    for (final menu in menus!) {
      if (menu.items != null && menu.items!.isNotEmpty) {
        for (final item in menu.items!) {
          allItems.add({
            'name': item.name,
            'price': item.price,
            'photoURL': item.photoUrl,
            'deliveryTime': item.deliveryTime,
          });
        }
      }
    }

    // Tomar máximo 3 items y priorizarlos por precio (más caros primero)
    allItems.sort((a, b) {
      final priceA = a['price'] as int? ?? 0;
      final priceB = b['price'] as int? ?? 0;
      return priceB.compareTo(priceA);
    });

    return allItems.take(3).toList();
  }

  /// Formatea el precio para mostrar
  String _formatPrice(int price) {
    if (price < 1000) {
      return '\$${price}';
    } else if (price < 10000) {
      final formatted = (price / 1000).toStringAsFixed(1);
      return '\$${formatted}k';
    } else {
      final formatted = (price / 1000).round();
      return '\$${formatted}k';
    }
  }
}

/// Molécula: Header de bienvenida del usuario
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
    return CustomerContainer(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Row(
        children: [
          // Avatar
          CustomerAvatar(size: isMobile ? 48 : 56),

          const SizedBox(width: 16),

          // Texto de bienvenida
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomerTitle(
                  text: '¡Hola, $userName!',
                  fontSize: isMobile ? 18 : 20,
                ),
                const SizedBox(height: 4),
                CustomerSubtitle(
                  text: 'Bienvenido a tu panel de cliente',
                  fontSize: isMobile ? 14 : 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Molécula: Notificación simple
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PUColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CustomerIcon(icon: icon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: PuTextStyle.brandHeadStyle.copyWith(
                color: PUColors.textColor2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
