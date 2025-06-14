import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../data/task_model.dart';
import '../data/db_helper.dart';
import '../core/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  List<Task> tasks = [];
  Task? editingTask;

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _pedirPermisoNotificaciones();
    _cargarTasks();
  }

  Future<void> _pedirPermisoNotificaciones() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        await FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
    }
  }

  Future<void> _cargarTasks() async {
    tasks = await DBHelper.getTasks();
    setState(() {});
  }

  Future<void> _guardarTask() async {
    if (_tituloController.text.isEmpty || _descController.text.isEmpty) return;
    final task = Task(
      id: editingTask?.id,
      titulo: _tituloController.text,
      descripcion: _descController.text,
    );
    if (editingTask == null) {
      await DBHelper.insertTask(task);
      await NotificationService.show('Tarea agregada', 'Se guardó: ${task.titulo}');
    } else {
      await DBHelper.updateTask(task);
      await NotificationService.show('Tarea actualizada', 'Se actualizó: ${task.titulo}');
    }
    _tituloController.clear();
    _descController.clear();
    editingTask = null;
    _cargarTasks();
  }

  Future<void> _borrarTask(int id) async {
    await DBHelper.deleteTask(id);
    await NotificationService.show('Tarea eliminada', 'Se eliminó la tarea');
    _cargarTasks();
  }

  void _editarTask(Task task) {
    setState(() {
      editingTask = task;
      _tituloController.text = task.titulo;
      _descController.text = task.descripcion;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Tareas y Actividades', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 14.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(editingTask == null ? Icons.add : Icons.edit),
                        label: Text(editingTask == null ? 'Agregar' : 'Actualizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _guardarTask,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: tasks.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 72, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text('No hay tareas registradas',
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    )
                  : ListView.separated(
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final t = tasks[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                            title: Text(
                              t.titulo,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            subtitle: Text(
                              t.descripcion,
                              style: const TextStyle(fontSize: 15),
                            ),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.indigo),
                                  tooltip: 'Editar',
                                  onPressed: () => _editarTask(t),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: 'Eliminar',
                                  onPressed: () => _borrarTask(t.id!),
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
