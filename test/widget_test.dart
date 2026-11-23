import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gestor_tareas_local/data/tareas_database.dart';
import 'package:gestor_tareas_local/screens/tareas_page.dart';

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    // Base temporal
    final db = TareasDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

    // Mostrar la base temporal.
    await tester.pumpWidget(MaterialApp(home: TareasPage(database: db)));
    await tester.pumpAndSettle();

    // Comprobación
    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    //liberar recursos
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
