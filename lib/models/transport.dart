class Transport {
  final int id;
  final String model;
  final String licensePlate;
  final bool availability;

  Transport({
    required this.id,
    required this.model,
    required this.licensePlate,
    required this.availability,
  });

  // Конвертация объекта в Map для сохранения в базу
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model': model,
      'licensePlate': licensePlate,
      'availability': availability ? 1 : 0, // SQLite не поддерживает bool, используем 0/1
    };
  }

  // Восстановление объекта из Map
  factory Transport.fromMap(Map<String, dynamic> map) {
    return Transport(
      id: map['id'],
      model: map['model'],
      licensePlate: map['licensePlate'],
      availability: map['availability'] == 1, // Преобразуем 0/1 в bool
    );
  }
}