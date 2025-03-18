import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transport_provider.dart';
import '../models/transport.dart';

class TransportManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transportProvider = Provider.of<TransportProvider>(context, listen: false);

    // Загружаем транспорт только один раз при первом построении
    Future<void> loadData() async {
      await transportProvider.loadTransports();
    }

    // Вызываем loadData один раз
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Transport"),
      ),
      body: Consumer<TransportProvider>(
        builder: (context, transportProvider, child) {
          if (transportProvider.transports.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: transportProvider.transports.length,
            itemBuilder: (context, index) {
              Transport transport = transportProvider.transports[index];
              return ListTile(
                title: Text("${transport.model}"),
                subtitle: Text("License Plate: ${transport.licensePlate}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red), // Кнопка удаления
                  onPressed: () {
                    // Удаляем транспорт
                    transportProvider.deleteTransport(transport.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransportDialog(context, transportProvider),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTransportDialog(BuildContext context, TransportProvider transportProvider) {
    final modelController = TextEditingController();
    final licensePlateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Transport"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: modelController,
                decoration: InputDecoration(labelText: "Model"),
              ),
              TextField(
                controller: licensePlateController,
                decoration: InputDecoration(labelText: "License Plate"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Добавляем новый транспорт
                transportProvider.addTransport(
                  Transport(
                    id: transportProvider.transports.length + 1,
                    model: modelController.text, // Используем введенные данные
                    licensePlate: licensePlateController.text, // Используем введенные данные
                    availability: true,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}