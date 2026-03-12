import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Widget moderno para seleccionar categorías con búsqueda
class CategoriaSelector extends StatefulWidget {
  final String? valorSeleccionado;
  final ValueChanged<String?> onChanged;
  final String? labelText;
  final String? hintText;
  final bool mostrarOtro;
  final String? Function(String?)? validator;

  const CategoriaSelector({
    super.key,
    this.valorSeleccionado,
    required this.onChanged,
    this.labelText = 'Categoría',
    this.hintText = 'Selecciona una categoría',
    this.mostrarOtro = true,
    this.validator,
  });

  @override
  State<CategoriaSelector> createState() => _CategoriaSelectorState();
}

class _CategoriaSelectorState extends State<CategoriaSelector> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _mostrandoOtroInput = false;
  final _otroController = TextEditingController();

  List<String> get _categoriasFiltradas {
    final todas = AppConstants.todasLasSubcategorias;
    if (_searchQuery.isEmpty) return todas;
    return todas.where((cat) =>
      cat.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _otroController.dispose();
    super.dispose();
  }

  void _mostrarSelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalContent(context),
    );
  }

  Widget _buildModalContent(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Título
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Seleccionar Categoría',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Buscador
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar categoría...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setModalState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setModalState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Lista de categorías
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categoriasFiltradas.length + (widget.mostrarOtro ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Opción "Otro" al final
                    if (widget.mostrarOtro && index == _categoriasFiltradas.length) {
                      return _buildOtroOption(context, setModalState);
                    }

                    final categoria = _categoriasFiltradas[index];
                    final isSelected = categoria == widget.valorSeleccionado;

                    return ListTile(
                      title: Text(
                        categoria,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.primary : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: AppTheme.primary)
                          : null,
                      onTap: () {
                        widget.onChanged(categoria);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOtroOption(BuildContext context, StateSetter setModalState) {
    if (_mostrandoOtroInput) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Especifica la categoría:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.grey600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _otroController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ej: Cerrajería',
                      filled: true,
                      fillColor: AppTheme.grey50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.grey200),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_otroController.text.trim().isNotEmpty) {
                      widget.onChanged('Otro: ${_otroController.text.trim()}');
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                setModalState(() => _mostrandoOtroInput = false);
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.add, color: AppTheme.accent),
      ),
      title: Text(
        'Otro (especificar)',
        style: TextStyle(
          color: AppTheme.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Si no encuentras tu categoría',
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.grey500,
        ),
      ),
      onTap: () {
        setModalState(() => _mostrandoOtroInput = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.valorSeleccionado,
      validator: widget.validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _mostrarSelectorModal(context),
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  prefixIcon: const Icon(Icons.category_outlined),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  errorText: state.hasError ? state.errorText : null,
                  filled: true,
                  fillColor: AppTheme.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.grey200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.grey200),
                  ),
                ),
                child: Text(
                  widget.valorSeleccionado ?? widget.hintText ?? 'Seleccionar',
                  style: TextStyle(
                    color: widget.valorSeleccionado != null
                        ? AppTheme.textPrimary
                        : AppTheme.grey400,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
