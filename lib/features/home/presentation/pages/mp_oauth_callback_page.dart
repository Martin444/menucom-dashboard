import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';

/// Página de callback para manejar la respuesta de OAuth de Mercado Pago
class MPOAuthCallbackPage extends StatefulWidget {
  const MPOAuthCallbackPage({super.key});

  @override
  State<MPOAuthCallbackPage> createState() => _MPOAuthCallbackPageState();
}

class _MPOAuthCallbackPageState extends State<MPOAuthCallbackPage> {
  final MPOAuthService _mpService = MPOAuthService();

  bool _isProcessing = true;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _handleOAuthCallback();
  }

  /// Manejar el callback de OAuth
  Future<void> _handleOAuthCallback() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Obtener parámetros de la URL
      final uri = Uri.base;
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];

      // El parámetro 'state' se puede usar para validación de seguridad si es necesario
      // final state = uri.queryParameters['state'];

      // Verificar si hay error en la autorización
      if (error != null) {
        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _errorMessage = 'Error de autorización: $error';
          if (errorDescription != null) {
            _errorMessage = '$_errorMessage\n$errorDescription';
          }
        });
        return;
      }

      // Verificar que se recibió el código de autorización
      if (code == null || code.isEmpty) {
        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _errorMessage = 'No se recibió el código de autorización de Mercado Pago';
        });
        return;
      }

      // Completar la vinculación
      const redirectUri = 'https://menu-comerce.netlify.app/oauth/callback';
      final success = await _mpService.completeLinking(code, redirectUri);

      if (success) {
        // Obtener información de la cuenta vinculada
        final accountEmail = await _mpService.getLinkedAccountEmail();

        setState(() {
          _isProcessing = false;
          _isSuccess = true;
          _successMessage = accountEmail != null
              ? 'Cuenta vinculada exitosamente:\n$accountEmail'
              : 'Cuenta de Mercado Pago vinculada exitosamente';
        });

        // Redirigir automáticamente después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _redirectToHome();
          }
        });
      } else {
        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _errorMessage = 'Error al completar la vinculación con Mercado Pago';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isSuccess = false;
        _errorMessage = 'Error inesperado: $e';
      });
    }
  }

  /// Redirigir al home
  void _redirectToHome() {
    Get.offAllNamed('/'); // Redirigir al home y limpiar stack
  }

  /// Intentar nuevamente
  Future<void> _retry() async {
    await _handleOAuthCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.bgHeader,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo o icono principal
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isProcessing
                      ? PUColors.bgButton.withOpacity(0.1)
                      : _isSuccess
                          ? PUColors.bgSucces.withOpacity(0.1)
                          : PUColors.bgError.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  _isProcessing
                      ? FluentIcons.arrow_sync_24_regular
                      : _isSuccess
                          ? FluentIcons.checkmark_circle_24_regular
                          : FluentIcons.error_circle_24_regular,
                  size: 40,
                  color: _isProcessing
                      ? PUColors.bgButton
                      : _isSuccess
                          ? PUColors.bgSucces
                          : PUColors.bgError,
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                _isProcessing
                    ? 'Procesando Vinculación'
                    : _isSuccess
                        ? '¡Vinculación Exitosa!'
                        : 'Error en Vinculación',
                style: PuTextStyle.title3.copyWith(
                  color: _isSuccess
                      ? PUColors.bgSucces
                      : _errorMessage != null
                          ? PUColors.bgError
                          : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Mensaje o indicador de carga
              if (_isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Completando vinculación con Mercado Pago...',
                  style: PuTextStyle.brandHeadStyle,
                  textAlign: TextAlign.center,
                ),
              ] else if (_isSuccess && _successMessage != null) ...[
                Icon(
                  FluentIcons.wallet_24_regular,
                  size: 48,
                  color: PUColors.bgSucces,
                ),
                const SizedBox(height: 16),
                Text(
                  _successMessage!,
                  style: PuTextStyle.brandHeadStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Serás redirigido automáticamente...',
                  style: PuTextStyle.brandHeadStyle.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: PuTextStyle.brandHeadStyle.copyWith(
                    color: PUColors.bgError,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              // Botones de acción
              if (!_isProcessing) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isSuccess) ...[
                      TextButton(
                        onPressed: _redirectToHome,
                        child: const Text('Volver al Inicio'),
                      ),
                      const SizedBox(width: 16),
                      ButtonPrimary(
                        onPressed: _retry,
                        title: 'Reintentar',
                        load: false,
                      ),
                    ] else ...[
                      ButtonPrimary(
                        onPressed: _redirectToHome,
                        title: 'Continuar',
                        load: false,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
