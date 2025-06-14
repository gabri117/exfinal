class Task {
  final int? id;
  final String titulo;
  final String descripcion;
  final String fechaHora; // formato ISO

  Task({this.id, required this.titulo, required this.descripcion, required this.fechaHora});

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'fechaHora': fechaHora,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        titulo: map['titulo'],
        descripcion: map['descripcion'],
        fechaHora: map['fechaHora'],
      );
}
