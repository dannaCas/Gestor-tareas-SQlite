//Capa de datos pendiente

/*La base NO incluye SQLite implementado. Investiga cómo crear una tabla de tareas
con Drift y cómo abrir una base persistente en Android, iOS, Windows, Linux,
macOS y web. Puedes decidir los nombres de los archivos y las clases.

No coloques consultas SQL dentro de build(). Documenta tus decisiones en el reporte.
*/


import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'tareas_database.g.dart';

// Tabla de las tareas
@DataClassName('TareaRegistro')
class Tareas extends Table {
  // Identificador único de cada tarea.
  IntColumn get id => integer().autoIncrement()();

  // Nombre de la tarea
  TextColumn get titulo => text()();

  // Marcador de completado | Pendiente 
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

// Base de datos 
@DriftDatabase(tables: [Tareas])
class TareasDatabase extends _$TareasDatabase {
  TareasDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'gestor_tareas_local',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.dart.js'),
              ),
            ),
      );

  // INSERT: Agrega una tarea.
  Future<int> agregarTarea(String titulo) {
    final tituloLimpio = titulo.trim();

    if (tituloLimpio.isEmpty) {
      throw ArgumentError('Por favor, ingresa un título.');
    }

    return into(tareas).insert(TareasCompanion.insert(titulo: tituloLimpio));
  }

  // SELECT: Consultar todas las tareas.
  Future<List<TareaRegistro>> consultarTareas() {
    return select(tareas).get();
  }


  // UPDATE: Modificar el título de una tarea.
  Future<int> editarTitulo(int id, String nuevoTitulo) {
    final tituloLimpio = nuevoTitulo.trim();

    if (tituloLimpio.isEmpty) {
      throw ArgumentError('El título no puede estar vacío.');
    }

    return (update(tareas)..where((tarea) => tarea.id.equals(id))).write(
      TareasCompanion(titulo: Value(tituloLimpio)),
    );
  }


  // UPDATE: Cambiar el estado de una tarea.
  Future<int> actualizarEstado(int id, bool completada) {
    return (update(tareas)..where((tarea) => tarea.id.equals(id))).write(
      TareasCompanion(completada: Value(completada)),
    );
  }


  // DELETE: Eliminar una tarea por su id.
  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((tarea) => tarea.id.equals(id))).go();
  }



  @override
  int get schemaVersion => 1;
}


