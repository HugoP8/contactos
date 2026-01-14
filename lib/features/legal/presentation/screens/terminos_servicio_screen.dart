import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla de Términos y Condiciones del Servicio
class TerminosServicioScreen extends StatelessWidget {
  const TerminosServicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.gavel,
                    size: 60,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Términos y Condiciones de Uso',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Introducción
            _buildSection(
              context,
              '1. Introducción',
              'Bienvenido a CONTACTOS. Al utilizar nuestra aplicación, usted acepta estar sujeto a los presentes Términos y Condiciones. Si no está de acuerdo con estos términos, le rogamos que no utilice la aplicación.',
            ),

            // Servicios
            _buildSection(
              context,
              '2. Servicios Ofrecidos',
              'CONTACTOS es una plataforma que conecta usuarios que buscan profesionales con proveedores de servicios. Facilitamos la publicación de solicitudes de trabajo y la búsqueda de profesionales calificados en diversas áreas.',
            ),

            // Registro
            _buildSection(
              context,
              '3. Registro y Cuenta de Usuario',
              'Para utilizar ciertos servicios de CONTACTOS, debe crear una cuenta proporcionando información veraz y completa. Usted es responsable de mantener la confidencialidad de su contraseña y de todas las actividades realizadas bajo su cuenta.',
            ),

            // Sistema de créditos
            _buildSection(
              context,
              '4. Sistema de Créditos',
              'CONTACTOS utiliza un sistema de créditos para acceder a ciertas funcionalidades:\n\n'
                  '• Los créditos pueden obtenerse mediante registro, referidos, compras o promociones\n'
                  '• Los créditos no tienen valor monetario y no son reembolsables\n'
                  '• Los créditos pueden caducar según las políticas establecidas\n'
                  '• Nos reservamos el derecho de ajustar las tarifas de créditos',
            ),

            // Membresías
            _buildSection(
              context,
              '5. Membresías Premium',
              'Ofrecemos diferentes niveles de membresía con beneficios adicionales:\n\n'
                  '• Las membresías se facturan según el plan seleccionado\n'
                  '• Los pagos se procesan de forma segura\n'
                  '• Las cancelaciones deben realizarse antes del siguiente período de facturación\n'
                  '• No se realizan reembolsos por períodos parciales',
            ),

            // Conducta
            _buildSection(
              context,
              '6. Conducta del Usuario',
              'Al usar CONTACTOS, usted acepta:\n\n'
                  '• No publicar contenido falso, engañoso o ilegal\n'
                  '• No utilizar la plataforma para actividades fraudulentas\n'
                  '• Respetar los derechos de propiedad intelectual\n'
                  '• Mantener un comportamiento respetuoso con otros usuarios\n'
                  '• No intentar acceder a cuentas de otros usuarios',
            ),

            // Responsabilidades
            _buildSection(
              context,
              '7. Limitación de Responsabilidad',
              'CONTACTOS actúa como intermediario entre usuarios y profesionales. No garantizamos la calidad de los servicios prestados por los profesionales listados en la plataforma. Los usuarios son responsables de verificar las credenciales y calificaciones de los profesionales antes de contratar sus servicios.',
            ),

            // Propiedad intelectual
            _buildSection(
              context,
              '8. Propiedad Intelectual',
              'Todo el contenido de CONTACTOS, incluyendo diseño, logotipos, texto, gráficos y código, es propiedad exclusiva de CONTACTOS o sus licenciantes y está protegido por las leyes de propiedad intelectual.',
            ),

            // Modificaciones
            _buildSection(
              context,
              '9. Modificaciones del Servicio',
              'Nos reservamos el derecho de modificar, suspender o discontinuar cualquier aspecto de la aplicación en cualquier momento, con o sin previo aviso. No seremos responsables ante usted o terceros por cualquier modificación, suspensión o interrupción del servicio.',
            ),

            // Terminación
            _buildSection(
              context,
              '10. Terminación',
              'Podemos suspender o terminar su acceso a CONTACTOS si consideramos que ha violado estos Términos y Condiciones. Usted puede cerrar su cuenta en cualquier momento desde la configuración de su perfil.',
            ),

            // Ley aplicable
            _buildSection(
              context,
              '11. Ley Aplicable',
              'Estos Términos y Condiciones se rigen por las leyes vigentes en Bolivia. Cualquier disputa relacionada con estos términos será resuelta en los tribunales competentes de Bolivia.',
            ),

            // Contacto
            _buildSection(
              context,
              '12. Contacto',
              'Si tiene preguntas sobre estos Términos y Condiciones, puede contactarnos a través de:\n\n'
                  '• Email: soporte@contactos.bo\n'
                  '• WhatsApp: +591 12345678\n'
                  '• Dentro de la aplicación: Configuración > Ayuda y Soporte',
            ),

            const SizedBox(height: 32),

            // Nota final
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.info.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppTheme.info, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Al continuar usando CONTACTOS, usted acepta estar sujeto a estos Términos y Condiciones. Le recomendamos revisar estos términos periódicamente.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
