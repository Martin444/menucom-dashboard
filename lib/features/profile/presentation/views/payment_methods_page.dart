import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/payments/oauth/mp_oauth.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final MPOAuthService _mpOAuthService = MPOAuthService();

  bool _isLoading = false;
  bool _isLinked = false;
  String? _accountEmail;
  String? _accountNickname;
  String? _accountCountry;
  String? _accountStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkMPStatus();
  }

  Future<void> _checkMPStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await _mpOAuthService.getAccountStatus();

      setState(() {
        _isLinked = status.isLinked;
        if (status.isLinked && status.account != null) {
          _accountEmail = status.account!.email;
          _accountNickname = status.account!.nickname;
          _accountCountry = status.account!.country;
          _accountStatus = status.account!.status;
        } else {
          _accountEmail = null;
          _accountNickname = null;
          _accountCountry = null;
          _accountStatus = null;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al verificar estado de Mercado Pago: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startMPLinking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      const redirectUri = 'https://tuapp.com/oauth/callback';
      final result = await _mpOAuthService.initiateLinkingFlow(redirectUri);

      if (result.isAlreadyLinked) {
        _showSnackBar('Ya hay una cuenta vinculada: ${result.linkedEmail}', Colors.orange);
        await _checkMPStatus();
      } else if (result.hasAuthUrl) {
        // Abrir URL de autorización
        final uri = Uri.parse(result.authUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          _showSnackBar('Redirigiendo a Mercado Pago para autorización...', Colors.blue);
        } else {
          throw 'No se puede abrir ${result.authUrl}';
        }
      } else {
        throw result.error ?? 'Error desconocido al iniciar vinculación';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar vinculación: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unlinkMPAccount() async {
    // Mostrar diálogo de confirmación
    final confirmed = await _showConfirmationDialog(
      title: 'Confirmar desvinculación',
      content: '¿Estás seguro de que quieres desvincular tu cuenta de Mercado Pago?',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _mpOAuthService.unlinkAccount();

      if (success) {
        _showSnackBar('Cuenta desvinculada exitosamente', Colors.green);
        await _checkMPStatus();
      } else {
        throw 'No se pudo desvincular la cuenta';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al desvincular cuenta: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshMPToken() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _mpOAuthService.refreshToken();

      if (success) {
        _showSnackBar('Token renovado exitosamente', Colors.green);
        await _checkMPStatus();
      } else {
        throw 'No se pudo renovar el token';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al renovar token: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header con botón de volver
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          Get.back();
                        } else {
                          Get.offAllNamed(PURoutes.HOME);
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(FluentIcons.arrow_left_24_regular),
                          Text(
                            'Volver',
                            style: PuTextStyle.description1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Título de la página
              Text(
                'Métodos de Pago',
                style: PuTextStyle.title1.copyWith(fontSize: 28),
              ),

              const SizedBox(height: 10),

              Text(
                'Configura tus métodos de pago para recibir dinero',
                style: PuTextStyle.description1,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Contenido principal
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Error message
                            if (_errorMessage != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(FluentIcons.error_circle_24_regular, color: Colors.red),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(color: Colors.red[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Mercado Pago Section
                            _buildMercadoPagoSection(),

                            const SizedBox(height: 30),

                            // Refresh button
                            ButtonPrimary(
                              title: 'Actualizar Estado',
                              onPressed: _checkMPStatus,
                              load: false,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMercadoPagoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PUColors.borderInputColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con logo
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF009EE3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FluentIcons.wallet_24_regular,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mercado Pago',
                      style: PuTextStyle.title2.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Plataforma de pagos de MercadoLibre',
                      style: PuTextStyle.description1.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isLinked ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isLinked ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _isLinked ? 'Vinculado' : 'No vinculado',
                  style: TextStyle(
                    color: _isLinked ? Colors.green[700] : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Información de la cuenta si está vinculada
          if (_isLinked) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la cuenta',
                    style: PuTextStyle.title3.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (_accountEmail != null) ...[
                    _buildInfoRow('Email', _accountEmail!),
                    const SizedBox(height: 8),
                  ],
                  if (_accountNickname != null) ...[
                    _buildInfoRow('Nickname', _accountNickname!),
                    const SizedBox(height: 8),
                  ],
                  if (_accountCountry != null) ...[
                    _buildInfoRow('País', _accountCountry!),
                    const SizedBox(height: 8),
                  ],
                  if (_accountStatus != null) ...[
                    _buildInfoRow('Estado', _accountStatus!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botones para cuenta vinculada
            Row(
              children: [
                Expanded(
                  child: ButtonPrimary(
                    title: 'Renovar Token',
                    onPressed: _refreshMPToken,
                    load: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _unlinkMPAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Desvincular',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Información para cuenta no vinculada
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    FluentIcons.info_24_regular,
                    color: Colors.blue[600],
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vincula tu cuenta de Mercado Pago',
                    style: PuTextStyle.title3.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para recibir pagos necesitas vincular tu cuenta de Mercado Pago. El proceso es seguro y solo toma unos minutos.',
                    style: PuTextStyle.description1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botón para vincular
            SizedBox(
              width: double.infinity,
              child: ButtonPrimary(
                title: 'Vincular Mercado Pago',
                onPressed: _startMPLinking,
                load: false,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: PuTextStyle.description1.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: PuTextStyle.description1,
          ),
        ),
      ],
    );
  }
}
