import 'package:flutter/cupertino.dart';

import '../database/database_helper.dart';
import '../models/transport.dart';

class TransportProvider with ChangeNotifier {
  List<Transport> _transports = [];

  List<Transport> get transports => _transports;

  // Загрузка транспорта из базы данных
  Future<void> loadTransports() async {
    final dbHelper = DatabaseHelper.instance;
    _transports = await dbHelper.getAllTransports();
    print("load trans $_transports");
    notifyListeners();
  }

  // Добавление транспорта
  Future<void> addTransport(Transport transport) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insertTransport(transport);
    await loadTransports(); // Перезагружаем список транспорта
  }

  // Обновление транспорта
  Future<void> updateTransport(Transport transport) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.updateTransport(transport);
    await loadTransports(); // Перезагружаем список транспорта
  }

  // Удаление транспорта
  Future<void> deleteTransport(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteTransport(id);
    await loadTransports(); // Перезагружаем список транспорта
  }

  // Получение доступного транспорта
  List<Transport> getAvailableTransports() {
    return _transports.where((transport) => transport.availability).toList();
  }
}