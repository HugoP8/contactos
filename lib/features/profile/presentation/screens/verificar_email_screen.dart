import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla para verificar el email del usuario
class VerificarEmailScreen extends ConsumerStatefulWidget {
  const VerificarEmailScreen({super.key});

  @override
  ConsumerState<VerificarEmailScreen> createState() => _VerificarEmailScreenState();
}

class _VerificarEmailScreenState extends ConsumerState<VerificarEmailScreen> {
  bool _isLoading = false;
  bool _emailEnviado = false;

  Future<void> _reenviarEmail() async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Supabase reenvía automáticamente el email de verificación
      await ref.read(authProvider.notifier).resendVerificationEmail();

      if (mounted) {
        setState(() => _emailEnviado = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Email de verificación enviado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar email: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verificar Email')),
        body: const Center(child: Text('No hay usuario autenticado')),
      );
    }

    final emailVerificado = user.verificado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Email'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // Icono y estado
            Center(
              child: Column(
                children: [
                  Icon(
                    emailVerificado ? Icons.verified_user : Icons.mail_outline,
                    size: 100,
                    color: emailVerificado ? AppTheme.success : AppTheme.warning,
                  ),
                  const SizedBox(height: 24),

                  // Título
                  Text(
                    emailVerificado ? '¡Email Verificado!' : 'Verifica tu Email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Email del usuario
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primary,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Descripción
                  Text(
                    emailVerificado
                        ? 'Tu email ha sido verificado correctamente.\n'
                            'Puedes acceder a todas las funciones de la app.'
                        : 'Hemos enviado un enlace de verificación a tu email.\n'
                            'Haz clic en el enlace para verificar tu cuenta.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            if (!emailVerificado) ...[
              // Botón de reenviar email
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading || _emailEnviado ? null : _reenviarEmail,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(_emailEnviado ? Icons.check : Icons.send),
                  label: Text(
                    _emailEnviado ? 'Email Enviado' : 'Reenviar Email de Verificación',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '¿No recibes el email?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem('Revisa tu carpeta de spam o correo no deseado'),
                    _buildInfoItem('Asegúrate de que tu email sea correcto'),
                    _buildInfoItem('Espera unos minutos antes de reenviar'),
                    _buildInfoItem('Contacta soporte si el problema persiste'),
                  ],
                ),
              ),
            ] else ...[
              // Email ya verificado - mostrar botón de volver
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Volver',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Beneficios de email verificado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: AppTheme.success, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Beneficios de verificación',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildBenefitItem('Seguridad adicional para tu cuenta'),
                    _buildBenefitItem('Recuperación de contraseña habilitada'),
                    _buildBenefitItem('Notificaciones por email'),
                    _buildBenefitItem('Mayor confianza de otros usuarios'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: AppTheme.info, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppTheme.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
