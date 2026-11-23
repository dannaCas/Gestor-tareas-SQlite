# Práctica 4 - Gestor de Tareas con SQLite

Aplicación multiplataforma desarrollada con **Flutter y Dart**, que permite administrar tareas mediante una base de datos SQLite local utilizando Drift.

El sistema realiza operaciones CRUD básicas y conserva las tareas después de cerrar y volver a abrir la aplicación, sin depender de un servidor ni de una conexión a internet.

## 1. Funcionalidades

- **Agregar tareas:** registrar una tarea con un título válido.
- **Consultar tareas:** mostrar los registros almacenados en SQLite.
- **Editar tareas:** modificar el título de una tarea existente.
- **Cambiar estado:** marcar una tarea como completada o pendiente.
- **Eliminar tareas:** borrar registros mediante su identificador, solicitando confirmación por parte del usuario.
- **Validación:** impedir que se registren títulos vacíos o compuestos únicamente por espacios.
- **Persistencia:** conservar los cambios entre ejecuciones.

## 2. Tecnologías utilizadas

| Tecnología | Función |
|---|---|
| Flutter y Dart | Desarrollo de la aplicación y su interfaz |
| SQLite | Almacenamiento local persistente |
| Drift | Definición de tablas y operaciones de base de datos |
| drift_flutter | Configuración multiplataforma de SQLite |
| drift_dev | Generación de código para Drift |
| build_runner | Ejecución de los generadores de código |
| flutter_test | Pruebas automatizadas |

## 3. Estructura del proyecto

- `lib/main.dart`: inicialización y configuración visual.
- `lib/models/tarea.dart`: modelo de tarea.
- `lib/data/tareas_database.dart`: tabla, conexión y operaciones CRUD.
- `lib/data/tareas_database.g.dart`: código generado automáticamente por Drift.
- `lib/screens/tareas_page.dart`: interfaz principal y manejo de las tareas.
- `test/widget_test.dart`: prueba de apertura de la interfaz.
- `test/tareas_database_test.dart`: pruebas de validación y operaciones.
- `web/sqlite3.wasm`: motor SQLite para el navegador.
- `web/drift_worker.dart.js`: recurso utilizado por Drift en web.

## 4. Base de datos

La aplicación utiliza una tabla llamada `tareas`:

| Campo | Tipo | Descripción |
|---|---|---|
| id | INTEGER | Clave primaria autoincremental |
| titulo | TEXT | Título de la tarea |
| completada | BOOLEAN | Estado de la tarea; Representado con 0 y 1 |

Las operaciones implementadas son INSERT, SELECT, UPDATE y DELETE.

La conexión se configura mediante `driftDatabase()`.

## 5. Instalación

**Requisitos:**
- Flutter SDK y Dart.
- Un editor compatible, como Visual Studio Code.
- Google Chrome para ejecutar la versión web.
- Visual Studio con herramientas de desarrollo C++ para compilar en Windows.
- Dispositivo Android con depuración USB activada o un emulador.

Clonar el repositorio:
`git clone URL_DEL_REPOSITORIO`

Entrar a la carpeta del proyecto:
`cd gestor_tareas_local`

Instalar las dependencias:
`flutter pub get`

Si es necesario regenerar el código de Drift:
`dart run build_runner build`

## 6. Ejecución

**Versión web (Chrome)**

`flutter run -d chrome --web-port 5050`

Los archivos `sqlite3.wasm` y `drift_worker.dart.js` se encuentran dentro de la carpeta `web/`.


**Versión Windows**

`flutter run -d windows`

La aplicación se ejecuta como programa de escritorio y utiliza almacenamiento SQLite local independiente del navegador.

**Versión Android**

`flutter devices`
`flutter run -d (id del dispositivo)`


**Plataformas verificadas:**

- Windows: ejecución nativa, operaciones CRUD y persistencia comprobadas.
- Chrome: ejecución web, operaciones CRUD y persistencia comprobadas.
- Android: ejecución móvil en un teléfono físico, operaciones CRUD y persistencia comprobadas.


## 7. Pruebas

**Pruebas manuales realizadas:**

- P1: agregar tres tareas y comprobar que permanecen al reiniciar.
- P2: cambiar el estado de una tarea y verificar su persistencia.
- P3: editar el título y comprobar que el cambio permanece.
- P4: eliminar una tarea y verificar que no reaparece.
- P5: intentar guardar títulos vacíos y comprobar su rechazo.
- P6: recargar y reabrir la aplicación web conservando las tareas en el mismo origen y perfil.

**Pruebas automatizadas:**

1. Rechazo de títulos vacíos o compuestos por espacios.
2. Operaciones CRUD con una base SQLite temporal.
3. Apertura y visualización de la interfaz principal.

Ejecutar todas las pruebas:

`flutter test`

Verificar el análisis estático:

`flutter analyze`

Las pruebas de base de datos utilizan `NativeDatabase.memory()` para no modificar los datos reales de la aplicación.

## 8. Referencias

Fuentes oficiales:
- [Flutter — Persistencia con SQLite](https://docs.flutter.dev/cookbook/persistence/sqlite): fundamentos del almacenamiento local.
- [Drift — Documentación oficial](https://drift.simonbinder.eu/): definición de tablas y operaciones de base de datos.
- [Drift — Web](https://drift.simonbinder.eu/platforms/web/): configuración de SQLite mediante WebAssembly.
- [drift_flutter](https://pub.dev/packages/drift_flutter): configuración de conexiones multiplataforma.
- [Flutter — Testing](https://docs.flutter.dev/testing/overview): creación y ejecución de pruebas automatizadas.
