import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transport_app/providers/auth_provider.dart';
import 'package:transport_app/providers/order_provider.dart';
import 'package:transport_app/providers/transport_provider.dart';
import 'package:transport_app/screens/login_screen.dart';
import 'package:transport_app/screens/orders_screen.dart';
import 'package:transport_app/database/database_helper.dart';
import 'package:transport_app/screens/transport_managment_screen.dart';

import 'models/transport.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await DatabaseHelper.instance.database;
  }
  // Добавляем тестовых пользователей
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.insertUser(User(
    id: 1,
    name: 'Employee',
    email: 'employee@test.com',
    password: 'password',
    userType: UserType.employee,
  ));
  await dbHelper.insertUser(User(
    id: 2,
    name: 'Client',
    email: 'client@test.com',
    password: 'password',
    userType: UserType.client,
  ));
  // Добавляем тестовый транспорт
  await dbHelper.insertTransport(Transport(
    id: 1,
    model: 'Toyota Camry',
    licensePlate: 'A123BC',
    availability: true,
  ));
  await dbHelper.insertTransport(Transport(
    id: 2,
    model: 'Ford Focus',
    licensePlate: 'B456DE',
    availability: false,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, authProvider, orderProvider) => orderProvider!
            ..loadOrders(authProvider.userId ?? 0, authProvider.isEmployee),
        ),
        ChangeNotifierProvider(create: (_) => TransportProvider()),
      ],
      child: MaterialApp(
        title: 'Transport Management App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/orders': (context) => OrdersScreen(),
          '/transport': (context) => TransportManagementScreen(), // Добавьте маршрут
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthProvider>(context, listen: false).checkLoginStatus(),
      builder: (context, snapshot) {
        final authProvider = Provider.of<AuthProvider>(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // Если пользователь вошел как работник, показываем список заказов
        return authProvider.isLoggedIn ? OrdersScreen() : LoginScreen();
      },
    );
  }
}
