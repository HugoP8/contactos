import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/models/perfil_profesional_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Card para mostrar un profesional en la lista de búsqueda
class ProfesionalCard extends StatelessWidget {
  final PerfilProfesionalModel profesional;

  const ProfesionalCard({
    super.key,
    required this.profesional,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/profesional/${profesional.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto de perfil
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: profesional.fotoPerfil != null
                    ? CachedNetworkImage(
                        imageUrl: profesional.fotoPerfil!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.grey200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.grey200,
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.grey400,
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: AppTheme.grey200,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.grey400,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profesional.nombreComercial ?? 'Sin nombre',
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profesional.verificado)
                          const Icon(
                            Icons.verified,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                        if (profesional.destacado)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Categoría
                    Text(
                      profesional.categoriaPrincipal,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),

                    // Descripción
                    if (profesional.descripcion != null)
                      Text(
                        profesional.descripcion!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),

                    // Calificación y ciudad
                    Row(
                      children: [
                        // Calificación
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profesional.calificacionPromedio.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${profesional.totalResenas})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),

                        // Ciudad
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppTheme.grey400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profesional.ciudad,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
