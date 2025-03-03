import 'package:transport_app/models/transport.dart';
import 'package:transport_app/models/user.dart';

enum OrderStatus { newOrder, inProgress, completed }

class Order {
  final int id;
  final DateTime date;
  final OrderStatus status;
  final int userId;       // Сохраняем ID пользователя, а не объект
  final int transportId;  // Сохраняем ID транспорта

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.userId,
    required this.transportId,
  });

  // Конвертация объекта в Map для сохранения в базу
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),  // Преобразуем DateTime в String
      'status': status.name,  // Сохраняем enum как String
      'userId': userId,
      'transportId': transportId,
    };
  }

  // Восстановление объекта из Map
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      date: DateTime.parse(map['date']),  // Конвертируем String обратно в DateTime
      status: OrderStatus.values.firstWhere((e) => e.name == map['status']),  // Конвертируем String в enum
      userId: map['userId'],
      transportId: map['transportId'],
    );
  }
}
