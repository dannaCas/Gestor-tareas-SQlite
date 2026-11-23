import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../data/tareas_database.dart';

// Pantalla base SIN persistencia ni operaciones CRUD implementadas.
// Conserva las indicaciones TODO para orientar tu trabajo.
class TareasPage extends StatefulWidget {
  const TareasPage({super.key, this.database});
  final TareasDatabase? database;
  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  List<Tarea> _tareas = [];

  late final TareasDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = widget.database ?? TareasDatabase();
    _cargarTareas();
  }

  // Cargar todas las tareas
  Future<void> _cargarTareas() async {
    try {
      final registros = await _db.consultarTareas();

      if (!mounted) return;

      setState(() {
        _tareas = registros.map((registro) {
          return Tarea(
            id: registro.id,
            titulo: registro.titulo,
            completada: registro.completada,
          );
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      _pendiente('Error al consultar tareas: $e');
    }
  }

  Future<void> _agregarTarea() async {
    final titulo = _tituloController.text;

    try {
      await _db.agregarTarea(titulo); // Guardar la tarea
      if (!mounted) return;

      _tituloController.clear(); // Limpiar el textbox

      // Actualizar la lista
      await _cargarTareas();
    } on ArgumentError {
      if (!mounted) return;
      _pendiente('Escribe un título válido.');
    } catch (e) {
      if (!mounted) return;
      _pendiente('Error al guardar la tarea: $e');
    }
  }

  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      final filasActualizadas = await _db.actualizarEstado(
        tarea.id,
        completada,
      );
      if (!mounted) return;
      if (filasActualizadas == 0) {
        _pendiente('No se encontró la tarea.');
        return;
      }

      // Volver a consultar
      await _cargarTareas();
    } catch (e) {
      if (!mounted) return;

      _pendiente('Error: $e');
    }
  }

  Future<void> _editarTarea(Tarea tarea) async {
    String tituloEditado = tarea.titulo;

    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextFormField(
            initialValue: tarea.titulo,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Título de la tarea',
              border: OutlineInputBorder(),
            ),
            onChanged: (valor) {
              tituloEditado = valor;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, tituloEditado);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (!mounted || nuevoTitulo == null) return;

    try {
      // Actualizar el títuloo
      final filasActualizadas = await _db.editarTitulo(tarea.id, nuevoTitulo);
      if (!mounted) return;
      if (filasActualizadas == 0) {
        _pendiente('No se encontró la tarea.');
        return;
      }

      // Consultar para actualizar la pantalla.
      await _cargarTareas();

      if (!mounted) return;

      _pendiente('Tarea actualizada correctamente.');
    } on ArgumentError {
      if (!mounted) return;
      _pendiente('El título no puede estar vacío.');
    } catch (e) {
      if (!mounted) return;
      _pendiente('Error $e');
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    // confirmación antes de eliminar.
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar tarea'),
          content: Text('¿Seguro que deseas eliminar "${tarea.titulo}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    // Si cancela
    if (!mounted || confirmar != true) return;

    try {
      final filasEliminadas = await _db.eliminarTarea(
        tarea.id,
      ); // Eliminar la tarea por id
      if (!mounted) return;
      if (filasEliminadas == 0) {
        _pendiente('No se encontró la tarea.');
        return;
      }

      // Actualizar las tareas
      await _cargarTareas();
      if (!mounted) return;

      _pendiente('Tarea eliminada correctamente.');
    } catch (e) {
      if (!mounted) return;

      _pendiente('Error: $e');
    }
  }

  void _pendiente(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _db.close(); // Cerrar la conexión
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: _tareas.isEmpty
                  ? const Center(child: Text('Todavía no hay tareas guardadas'))
                  : ListView.builder(
                      itemCount: _tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = _tareas[index];
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: tarea.completada,
                              onChanged: (valor) {
                                if (valor != null) {
                                  _alternarCompletada(tarea, valor);
                                }
                              },
                            ),
                            title: Text(tarea.titulo),
                            subtitle: Text('ID: ${tarea.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editarTarea(tarea),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _eliminarTarea(tarea),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
