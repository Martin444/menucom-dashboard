import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'share_link_menu_dialog.dart';

/// Widget que verifica la vinculación de Mercado Pago antes de mostrar el diálogo de compartir
class MPOAuthGateWidget extends StatefulWidget {
  final String idMenu;
  final String redirectUri;

  const MPOAuthGateWidget({
    super.key,
    required this.idMenu,
    required this.redirectUri,
  });

  @override
  State<MPOAuthGateWidget> createState() => _MPOAuthGateWidgetState();
}

class _MPOAuthGateWidgetState extends State<MPOAuthGateWidget> {
  final MPOAuthService _mpService = MPOAuthService();

  bool _isCheckingStatus = true;
  bool _isLinked = false;
  bool _isLinking = false;
  String? _errorMessage;
  String? _accountEmail;

  @override
  void initState() {
    super.initState();
    _checkMPLinkingStatus();
  }

  /// Verificar el estado de vinculación al inicializar
  Future<void> _checkMPLinkingStatus() async {
    setState(() {
      _isCheckingStatus = true;
      _errorMessage = null;
    });

    try {
      final isLinked = await _mpService.isAccountLinked();

      if (isLinked) {
        // Si está vinculado, obtener información de la cuenta
        final accountEmail = await _mpService.getLinkedAccountEmail();

        setState(() {
          _isLinked = true;
          _accountEmail = accountEmail;
          _isCheckingStatus = false;
        });

        // Si está vinculado, mostrar directamente el diálogo de compartir
        _showShareDialog();
      } else {
        setState(() {
          _isLinked = false;
          _isCheckingStatus = false;
        });

        // Si no está vinculado, iniciar el proceso automáticamente
        await _startMPLinking();
      }
    } catch (e) {
      setState(() {
        _isCheckingStatus = false;
        _errorMessage = 'Error al verificar vinculación: $e';
      });
    }
  }

  /// Iniciar proceso de vinculación automáticamente
  Future<void> _startMPLinking() async {
    setState(() {
      _isLinking = true;
      _errorMessage = null;
    });

    try {
      final result = await _mpService.initiateLinkingFlow(widget.redirectUri);

      if (result.isAlreadyLinked) {
        // Caso edge: ya estaba vinculado
        setState(() {
          _isLinked = true;
          _isLinking = false;
          _accountEmail = result.linkedEmail;
        });
        _showShareDialog();
      } else if (result.hasAuthUrl) {
        // Abrir URL de autorización
        final authUrl = result.authUrl!;

        if (await canLaunchUrl(Uri.parse(authUrl))) {
          await launchUrl(
            Uri.parse(authUrl),
            mode: LaunchMode.externalApplication,
          );

          // Mostrar mensaje de que debe completar en el navegador
          setState(() {
            _isLinking = false;
          });

          _showLinkingInProgressDialog();
        } else {
          throw 'No se puede abrir la URL de autorización';
        }
      } else {
        throw result.error ?? 'Error desconocido al iniciar vinculación';
      }
    } catch (e) {
      setState(() {
        _isLinking = false;
        _errorMessage = 'Error al iniciar vinculación: $e';
      });
    }
  }

  /// Mostrar diálogo de compartir cuando está vinculado
  void _showShareDialog() {
    // Cerrar este diálogo primero
    Navigator.of(context).pop();

    // Mostrar el diálogo de compartir
    showDialog(
      context: context,
      builder: (context) => ShareLinkMenuDialog(idMenu: widget.idMenu),
    );
  }

  /// Mostrar diálogo informativo sobre el proceso en curso
  void _showLinkingInProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LinkingInProgressDialog(
        onRefresh: () {
          Navigator.of(context).pop(); // Cerrar diálogo de progreso
          _checkMPLinkingStatus(); // Revalidar estado
        },
        onCancel: () {
          Navigator.of(context).pop(); // Cerrar diálogo de progreso
          Navigator.of(context).pop(); // Cerrar este widget
        },
      ),
    );
  }

  /// Reintentar vinculación manual
  Future<void> _retryLinking() async {
    await _startMPLinking();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        color: PUColors.bgHeader,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Text(
              'Vinculación de Mercado Pago',
              style: PuTextStyle.title3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Estado de carga inicial
            if (_isCheckingStatus) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Verificando vinculación...',
                style: PuTextStyle.brandHeadStyle,
                textAlign: TextAlign.center,
              ),
            ]

            // Estado de vinculación en progreso
            else if (_isLinking) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Iniciando vinculación...',
                style: PuTextStyle.brandHeadStyle,
                textAlign: TextAlign.center,
              ),
            ]

            // Error
            else if (_errorMessage != null) ...[
              Icon(
                Icons.error_outline,
                size: 48,
                color: PUColors.bgError,
              ),
              const SizedBox(height: 16),
              Text(
                'Error de Vinculación',
                style: PuTextStyle.title3.copyWith(
                  color: PUColors.bgError,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: PuTextStyle.brandHeadStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar'),
                  ),
                  ButtonPrimary(
                    onPressed: _retryLinking,
                    title: 'Reintentar',
                    load: false,
                  ),
                ],
              ),
            ]

            // Estado: no vinculado (no debería llegar aquí normalmente)
            else if (!_isLinked) ...[
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: PUColors.bgButton,
              ),
              const SizedBox(height: 16),
              Text(
                'Vinculación Requerida',
                style: PuTextStyle.title3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Para compartir el menú necesitas vincular tu cuenta de Mercado Pago',
                style: PuTextStyle.brandHeadStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar'),
                  ),
                  ButtonPrimary(
                    onPressed: _startMPLinking,
                    title: 'Vincular Ahora',
                    load: false,
                  ),
                ],
              ),
            ]

            // Estado: vinculado (no debería llegar aquí, se abre automáticamente)
            else ...[
              Icon(
                Icons.check_circle,
                size: 48,
                color: PUColors.bgSucces,
              ),
              const SizedBox(height: 16),
              Text(
                '¡Cuenta Vinculada!',
                style: PuTextStyle.title3.copyWith(
                  color: PUColors.bgSucces,
                ),
                textAlign: TextAlign.center,
              ),
              if (_accountEmail != null) ...[
                const SizedBox(height: 8),
                Text(
                  _accountEmail!,
                  style: PuTextStyle.brandHeadStyle,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              ButtonPrimary(
                onPressed: _showShareDialog,
                title: 'Continuar',
                load: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Diálogo que se muestra mientras el usuario completa la vinculación en el navegador
class _LinkingInProgressDialog extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onCancel;

  const _LinkingInProgressDialog({
    required this.onRefresh,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        color: PUColors.bgHeader,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.open_in_browser,
              size: 48,
              color: PUColors.bgButton,
            ),
            const SizedBox(height: 16),
            Text(
              'Autorización en Progreso',
              style: PuTextStyle.title3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Se abrió Mercado Pago en tu navegador.\n\n'
              '1. Autoriza la aplicación\n'
              '2. Regresa aquí\n'
              '3. Presiona "Verificar"',
              style: PuTextStyle.brandHeadStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: Text('Cancelar'),
                ),
                ButtonPrimary(
                  onPressed: onRefresh,
                  title: 'Verificar',
                  load: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
