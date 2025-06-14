Gestor de Tareas con SQLite y Notificaciones Locales
Aplicación móvil desarrollada en Flutter para registrar, consultar, actualizar y eliminar tareas o actividades.
Los datos se almacenan localmente usando SQLite y la app envía notificaciones locales cada vez que se realiza una acción importante.

Características principales
Registro, consulta, edición y eliminación de tareas (CRUD).

Notificaciones locales instantáneas al crear, modificar o borrar una tarea.

Interfaz moderna, sencilla y fácil de usar.

Datos persistentes utilizando SQLite.

Estructura del código organizada en tres capas:

presentation/ (pantallas y widgets)

data/ (modelo y acceso a base de datos)

core/ (servicio de notificaciones)


Instalación y ejecución
Clona este repositorio:


git clone [URL_DEL_REPOSITORIO]
cd [NOMBRE_DEL_PROYECTO]
Instala las dependencias:


flutter pub get
Ejecuta la app en un emulador o dispositivo físico:


flutter run
Dependencias principales
sqflite

path

flutter_local_notifications

device_info_plus

Permisos requeridos
Notificaciones:
La app solicita el permiso de notificaciones en Android 13 o superior de forma automática.

Estructura del proyecto

lib/
├── core/               # Servicios generales (notificaciones)
├── data/               # Modelos y base de datos
├── presentation/       # Pantallas y widgets
└── main.dart
Autor
José Gabriel Morales Galindo

gabri117