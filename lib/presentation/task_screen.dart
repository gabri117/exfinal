import 'package:flutter/material.dart';
import '../data/task_model.dart';
import '../data/db_helper.dart';
import '../core/notification_service.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDateTime;
  List<Task> tasks = [];
  Task? taskEditando;

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _cargarTasks();
  }

  Future<void> _cargarTasks() async {
    tasks = await DBHelper.getTasks();
    setState(() {});
  }

  Future<void> _guardarTask() async {
    if (_tituloController.text.isEmpty || _descController.text.isEmpty || _selectedDateTime == null) return;
    final task = Task(
      id: taskEditando?.id,
      titulo: _tituloController.text,
      descripcion: _descController.text,
      fechaHora: _selectedDateTime!.toIso8601String(),
    );
    if (taskEditando == null) {
      await DBHelper.insertTask(task);
      await NotificationService.show('Tarea agregada', 'Se guardó: ${task.titulo}');
      // Valor agregado: programar recordatorio
      await NotificationService.showScheduled('¡Recordatorio!', 'No olvides: ${task.titulo}', _selectedDateTime!);
    } else {
      await DBHelper.updateTask(task);
      await NotificationService.show('Tarea actualizada', 'Se actualizó: ${task.titulo}');
    }
    _tituloController.clear();
    _descController.clear();
    _selectedDateTime = null;
    taskEditando = null;
    _cargarTasks();
  }

  Future<void> _borrarTask(int id) async {
    await DBHelper.deleteTask(id);
    await NotificationService.show('Tarea eliminada', 'Se eliminó la tarea');
    _cargarTasks();
  }

  void _editarTask(Task task) {
    setState(() {
      taskEditando = task;
      _tituloController.text = task.titulo;
      _descController.text = task.descripcion;
      _selectedDateTime = DateTime.parse(task.fechaHora);
    });
  }

  Future<void> _seleccionarFechaHora() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tareas y Recordatorios')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _tituloController, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(_selectedDateTime == null
                    ? 'Seleccionar fecha y hora'
                    : 'Fecha: ${_selectedDateTime!.toLocal()}'),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _seleccionarFechaHora,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _guardarTask,
              child: Text(taskEditando == null ? 'Agregar' : 'Actualizar'),
            ),
            const Divider(),
            Expanded(
              child: tasks.isEmpty
                ? const Center(child: Text('No hay tareas registradas'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final t = tasks[index];
                      return ListTile(
                        title: Text(t.titulo),
                        subtitle: Text('${t.descripcion}\n${DateTime.parse(t.fechaHora).toLocal()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editarTask(t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _borrarTask(t.id!),
                            ),
                          ],
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
