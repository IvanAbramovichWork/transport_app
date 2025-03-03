import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transport_app/models/order.dart';
import 'package:transport_app/providers/order_provider.dart';
import 'package:transport_app/screens/add_edit_order_screen.dart';
import 'package:transport_app/screens/transport_managment_screen.dart';

import '../providers/auth_provider.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userId = authProvider.userId ?? 0;

    // Загружаем заказы один раз при построении экрана
    Future<void> loadOrdersFuture = orderProvider.loadOrders(userId, authProvider.isEmployee);

    return Scaffold(
      appBar: AppBar(
        title: Text('Список заказов'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => orderProvider.loadOrders(userId, authProvider.isEmployee),
          ),
          IconButton(
            icon: Icon(Icons.directions_car), // Иконка для перехода к управлению транспортом
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransportManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.orders.isEmpty) {
            return Center(child: Text('Нет заказов'));
          }

          return ListView.builder(
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];

              return ListTile(
                title: Text('Заказ #${order.id}'),
                subtitle: Text('Статус: ${order.status.name}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditOrderScreen(order: order),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteOrder(context, order.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditOrderScreen(),
            ),
          );
        },
      ),
    );
  }

  void _deleteOrder(BuildContext context, int orderId) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userId = authProvider.userId ?? 0;
    await orderProvider.deleteOrder(orderId, userId, authProvider.isEmployee);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Заказ удален')),
    );
  }
}