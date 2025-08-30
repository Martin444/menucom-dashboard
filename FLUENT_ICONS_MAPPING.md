# Mapeo de Material Icons a FluentUI System Icons

Este documento resume el mapeo realizado de Material Icons a FluentUI System Icons en el proyecto menucom-dashboard.

## Archivos Actualizados

### 1. Features - Profile
- **profile_page.dart**
  - `Icons.arrow_back_ios` → `FluentIcons.arrow_left_24_regular`
  - `Icons.arrow_forward_ios` → `FluentIcons.arrow_right_24_regular`

- **payment_methods_page.dart**
  - `Icons.arrow_back_ios` → `FluentIcons.arrow_left_24_regular`
  - `Icons.error` → `FluentIcons.error_circle_24_regular`
  - `Icons.account_balance_wallet` → `FluentIcons.wallet_24_regular`
  - `Icons.info_outline` → `FluentIcons.info_24_regular`

### 2. Features - Wardrobes
- **create_ward_page.dart**
  - `Icons.arrow_back_ios` → `FluentIcons.arrow_left_24_regular`

- **create_ward_item_page.dart**
  - `Icons.arrow_back_ios` → `FluentIcons.arrow_left_24_regular`

### 3. Features - Orders
- **orders_metrics_widget.dart**
  - `Icons.attach_money` → `FluentIcons.money_24_regular`
  - `Icons.receipt_long` → `FluentIcons.receipt_24_regular`
  - `Icons.hourglass_empty` → `FluentIcons.hourglass_24_regular`
  - `Icons.autorenew` → `FluentIcons.arrow_sync_24_regular`
  - `Icons.check_circle` → `FluentIcons.checkmark_circle_24_regular`

- **orders_page.dart**
  - `Icons.menu` → `FluentIcons.line_horizontal_3_24_regular`
  - `Icons.refresh` → `FluentIcons.arrow_sync_24_regular`
  - `Icons.error_outline` → `FluentIcons.error_circle_24_regular`
  - `Icons.receipt_long_outlined` → `FluentIcons.receipt_24_regular`

### 4. Features - Menu
- **card_take_photo.dart**
  - `Icons.camera_enhance` → `FluentIcons.camera_24_regular`

- **create_menu_page.dart**
  - `Icons.arrow_back_ios` → `FluentIcons.arrow_left_24_regular`

- **create_item_page.dart**
  - `Icons.arrow_back_ios` → `FluentIcons.arrow_left_24_regular`

### 5. Features - Home
- **head_dinning.dart**
  - `Icons.notifications_outlined` → `FluentIcons.alert_24_regular`

- **mp_oauth_callback_page.dart**
  - `Icons.sync` → `FluentIcons.arrow_sync_24_regular`
  - `Icons.check_circle` → `FluentIcons.checkmark_circle_24_regular`
  - `Icons.error_outline` → `FluentIcons.error_circle_24_regular`
  - `Icons.account_balance_wallet` → `FluentIcons.wallet_24_regular`

- **form_edit_side.dart**
  - `Icons.arrow_back_ios` → `FluentIcons.arrow_left_24_regular`

- **ward_home_view.dart**
  - `Icons.checkroom` → `FluentIcons.folder_24_regular`

- **menu_home_view.dart**
  - `Icons.restaurant_menu` → `FluentIcons.food_24_regular`

- **share_link_menu_dialog.dart**
  - `Icons.copy` → `FluentIcons.copy_24_regular`

## Mapeo de Iconos Comunes

| Material Icon | FluentUI System Icon | Uso |
|---------------|---------------------|-----|
| `Icons.arrow_back_ios` | `FluentIcons.arrow_left_24_regular` | Navegación hacia atrás |
| `Icons.arrow_forward_ios` | `FluentIcons.arrow_right_24_regular` | Navegación hacia adelante |
| `Icons.error` / `Icons.error_outline` | `FluentIcons.error_circle_24_regular` | Estados de error |
| `Icons.check_circle` | `FluentIcons.checkmark_circle_24_regular` | Estados de éxito |
| `Icons.refresh` / `Icons.autorenew` | `FluentIcons.arrow_sync_24_regular` | Refrescar/Sincronizar |
| `Icons.notifications_outlined` | `FluentIcons.alert_24_regular` | Notificaciones |
| `Icons.account_balance_wallet` | `FluentIcons.wallet_24_regular` | Billetera/Pagos |
| `Icons.copy` | `FluentIcons.copy_24_regular` | Copiar |
| `Icons.camera_enhance` | `FluentIcons.camera_24_regular` | Cámara |
| `Icons.attach_money` | `FluentIcons.money_24_regular` | Dinero/Precio |
| `Icons.receipt_long` | `FluentIcons.receipt_24_regular` | Recibos/Facturas |
| `Icons.hourglass_empty` | `FluentIcons.hourglass_24_regular` | Tiempo/Espera |
| `Icons.menu` | `FluentIcons.line_horizontal_3_24_regular` | Menú hamburguesa |
| `Icons.info_outline` | `FluentIcons.info_24_regular` | Información |
| `Icons.restaurant_menu` | `FluentIcons.food_24_regular` | Menú de comida |
| `Icons.checkroom` | `FluentIcons.folder_24_regular` | Guardarropa |

## Archivos que Necesitan Import

Todos los archivos modificados ahora incluyen:
```dart
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
```

## Próximos Pasos

## PUIcons SVG to FluentUI Icons Migration

### 1. Main App - Navigation
- **menu_navigation_items.dart**
  - `PUIcons.iconHomeMenu` → `FluentIcons.home_24_regular`
  - `PUIcons.iconOrderMenu` → `FluentIcons.clipboard_task_list_ltr_24_regular`
  - `PUIcons.iconSalesMenu` → `FluentIcons.money_24_regular`
  - `PUIcons.iconClientsMenu` → `FluentIcons.people_24_regular`
  - `PUIcons.iconProveeMenu` → `FluentIcons.building_24_regular`
  - `PUIcons.iconExitMenu` → `FluentIcons.sign_out_24_regular`
  - **Note**: Changed MenuItemConfig.icon from String to IconData

- **enhanced_menu_draw_item.dart**
  - Updated SvgPicture.asset usage to Icon widget for FluentUI compatibility

### 2. Main App - Widgets
- **button_logo.dart**
  - Converted from SVG-based to IconData-based widget
  - `PUIcons.iconCart` → `FluentIcons.shopping_bag_24_regular` (default)
  - Added iconColor, iconSize parameters
  - **Note**: Breaking change - pathIcon parameter replaced with icon (IconData)

- **share_link_menu_dialog.dart**
  - `PUIcons.iconWhatsapp` → `FluentIcons.chat_24_regular`
  - `PUIcons.iconGmail` → `FluentIcons.mail_24_regular`
  - `PUIcons.iconDownload` → `FluentIcons.arrow_download_24_regular`

- **item_category_tile.dart**
  - `PUIcons.iconEdit` → `FluentIcons.edit_24_regular`
  - `PUIcons.iconDelete` → `FluentIcons.delete_24_regular`
  - Updated from SvgPicture.asset to Icon widgets

- **head_actions.dart**
  - `PUIcons.iconLink` → `FluentIcons.link_24_regular`
  - Updated from SvgPicture.asset to Icon widget

- **category_tags_section.dart**
  - `PUIcons.iconEdit` → `FluentIcons.edit_24_regular`
  - `PUIcons.iconDelete` → `FluentIcons.delete_24_regular`
  - Updated from SvgPicture.asset to Icon widgets

### 3. PU_Material Library - Widgets
- **pu_input.dart**
  - `PUIcons.iconEyeOpen` → `FluentIcons.eye_24_regular`
  - `PUIcons.iconEyeClose` → `FluentIcons.eye_off_24_regular`
  - Updated from SvgPicture.asset to Icon widget

- **cart_icon_button.dart**
  - `PUIcons.iconCheck` → `FluentIcons.checkmark_24_regular` (default selected)
  - `PUIcons.iconCart` → `FluentIcons.shopping_bag_24_regular` (default unselected)
  - **Note**: Breaking change - selectedIcon/unselectedIcon changed from String to IconData

## Breaking Changes Summary

1. **MenuItemConfig.icon**: Changed from `String` to `IconData`
2. **LogoButton.pathIcon**: Replaced with `icon` parameter (IconData)
3. **CartIconButton**: selectedIcon/unselectedIcon changed from String to IconData
4. **SVG Dependencies**: Removed svg_flutter dependencies where FluentUI icons are used

## Deprecated PUIcons

The following PUIcons are no longer needed as they've been replaced with FluentUI equivalents:
- iconHomeMenu, iconOrderMenu, iconSalesMenu, iconClientsMenu
- iconProveeMenu, iconExitMenu, iconLink, iconEdit, iconDelete
- iconCart, iconCheck, iconEyeOpen, iconEyeClose
- iconWhatsapp, iconGmail, iconDownload

## Notes

- All icon sizes standardized to 24px for consistency
- Added color parameters where appropriate for better customization
- Maintained visual hierarchy and accessibility standards
- **✅ COMPLETADO**: Migration from SVG-based PUIcons to FluentUI System Icons completed

### 1. PU_Material - Atoms
- **progress_dot.dart**
  - `Icons.check` → `FluentIcons.checkmark_24_regular`

- **ward_statistics_atom.dart**
  - `Icons.people` → `FluentIcons.person_24_regular`
  - `Icons.grid_view` → `FluentIcons.grid_24_regular`
  - `Icons.attach_money` → `FluentIcons.money_24_regular`

### 2. PU_Material - Widgets
- **mc_option_buttons_tile.dart**
  - `Icons.edit` → `FluentIcons.edit_24_regular`
  - `Icons.delete` → `FluentIcons.delete_24_regular`
  - `Icons.more_vert` → `FluentIcons.more_vertical_24_regular`

- **warning_dialog.dart**
  - `Icons.warning` → `FluentIcons.warning_24_regular`

- **pu_input_tags.dart**
  - `Icons.close` → `FluentIcons.dismiss_24_regular`

- **cart_tile.dart**
  - `Icons.remove` → `FluentIcons.subtract_24_regular`
  - `Icons.add` → `FluentIcons.add_24_regular`

- **pu_robust_network_image.dart**
  - `Icons.image_not_supported` → `FluentIcons.image_off_24_regular`

- **pu_robust_network_image_isolate.dart**
  - `Icons.image_not_supported` → `FluentIcons.image_off_24_regular`

### 3. PU_Material - Molecules
- **category_sidebar.dart**
  - `Icons.edit` → `FluentIcons.edit_24_regular`
  - `Icons.delete` → `FluentIcons.delete_24_regular`

### 4. PU_Material - Organisms
- **status_header.dart**
  - `Icons.sync` → `FluentIcons.arrow_sync_24_regular`

### 5. PU_Material - Pages
- **image_test_page.dart**
  - `Icons.error` → `FluentIcons.error_circle_24_regular`

## Dependencies Updated

- **Main App pubspec.yaml**: Added `fluentui_system_icons: ^1.1.273`
- **PU_Material pubspec.yaml**: Added `fluentui_system_icons: ^1.1.273`

## Próximos Pasos

1. **Testing**: Ejecutar las pruebas para asegurar que todos los iconos se muestran correctamente.
2. **Revisar otros archivos**: Buscar posibles iconos que puedan haberse perdido en otros archivos del proyecto.

## Notas Importantes

- Se mantiene el tamaño `24_regular` para consistencia visual.
- Algunos iconos pueden requerir ajustes visuales adicionales según el contexto.
- Los imports se agregaron automáticamente pero aparecen como "unused" hasta que el proyecto se compile.
- **✅ COMPLETADO**: Tanto la aplicación principal como la librería pu_material han sido actualizadas.
