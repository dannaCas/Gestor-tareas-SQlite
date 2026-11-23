import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../data/tareas_database.dart';

// Pantalla base SIN persistencia ni operaciones CRUD implementadas.
// Conserva las indicaciones TODO para orientar tu trabajo.
class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  List<Tarea> _tareas = [];

  final TareasDatabase _db = TareasDatabase();


@override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  // Recupera las tareas almacenadas en SQLite.
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
      // Guardar la tarea
      await _db.agregarTarea(titulo);

      if (!mounted) return;

      // Limpiar el campo de texto.
      _tituloController.clear();

      // Actualizar la lista con los datos guardados.
      await _cargarTareas();
    } on ArgumentError {
      if (!mounted) return;
      _pendiente('Escribe un título válido.');
    } catch (e) {
      if (!mounted) return;
      _pendiente('Error al guardar la tarea: $e');
    }
  }


  void _alternarCompletada(Tarea tarea, bool completada) {
    _pendiente('Implementar actualización de tarea');
  }

  void _editarTarea(Tarea tarea) {
    _pendiente('Implementar edición de título');
  }

  void _eliminarTarea(Tarea tarea) {
    _pendiente('Implementar eliminación de tarea');
  }

  void _pendiente(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _db.close(); // Cerrar la conexión cuando se destruye la pantalla
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
