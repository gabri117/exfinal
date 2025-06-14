class Task {
  final int? id;
  final String titulo;
  final String descripcion;

  Task({this.id, required this.titulo, required this.descripcion});

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        titulo: map['titulo'],
        descripcion: map['descripcion'],
      );
}
