import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/tareas_database.dart';

void main() {
  late TareasDatabase db;

  // Base temporal
  setUp(() {
    db = TareasDatabase(NativeDatabase.memory());
  });

  // Cerrar base de datos
  tearDown(() async {
    await db.close();
  });

  // PRUEBA 1: Validación de títulos
  test('No permite agregar tareas con titulo vacio', () async {
    expect(() => db.agregarTarea('   '), throwsArgumentError);
    final tareas = await db.consultarTareas();
    expect(tareas, isEmpty);
  });

  // PRUEBA 2: Operaciones CRUD
  test('Operaciones CRUD en SQLite', () async {
    // Agregar
    final id = await db.agregarTarea('Estudiar SQLite');
    var tareas = await db.consultarTareas();

    expect(tareas.length, 1);
    expect(tareas.first.titulo, 'Estudiar SQLite');
    expect(tareas.first.completada, false);

    // Editar título
    await db.editarTitulo(id, 'Estudiar Drift');
    tareas = await db.consultarTareas();
    expect(tareas.first.titulo, 'Estudiar Drift');

    // Marcar como completada
    await db.actualizarEstado(id, true);
    tareas = await db.consultarTareas();
    expect(tareas.first.completada, true);

    // Eliminar
    await db.eliminarTarea(id);
    tareas = await db.consultarTareas();
    expect(tareas, isEmpty);
  });
}
