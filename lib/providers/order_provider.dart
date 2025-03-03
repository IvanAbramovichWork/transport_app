import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  List<Order> get orders => _orders;

  Future<void> initializeOrders(int userId, bool isEmployee) async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> ordersData;
    if (isEmployee) {
      ordersData = await db.query('orders'); // Все заказы для сотрудников
    } else {
      ordersData = await db.query('orders', where: 'userId = ?', whereArgs: [userId]); // Только заказы клиента
    }

    _orders = ordersData.map((data) => Order.fromMap(data)).toList();
    notifyListeners();
  }


  Future<void> loadOrders(int userId, bool isEmployee) async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> ordersData;
    if (isEmployee) {
      ordersData = await db.query('orders');
    } else {
      ordersData = await db.query('orders', where: 'userId = ?', whereArgs: [userId]);
    }

    _orders = ordersData.map((data) => Order.fromMap(data)).toList();
    notifyListeners(); // Уведомляем слушателей
  }

  Future<void> addOrder(Order order) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('orders', order.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await loadOrders(order.userId, false);
    notifyListeners();
  }

  Future<void> updateOrder(Order order) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('orders', order.toMap(), where: 'id = ?', whereArgs: [order.id]);
    await loadOrders(order.userId, false);
    notifyListeners(); // Уведомляем слушателей
  }

  Future<void> deleteOrder(int orderId, int userId, bool isEmployee) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('orders', where: 'id = ?', whereArgs: [orderId]);
    await loadOrders(userId, isEmployee); // Перезагружаем заказы
    notifyListeners(); // Уведомляем слушателей
  }
}
