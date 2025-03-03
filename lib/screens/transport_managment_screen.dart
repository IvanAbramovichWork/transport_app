import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transport_provider.dart';
import '../models/transport.dart';

class TransportManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transportProvider = Provider.of<TransportProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Transport"),
      ),
      body: FutureBuilder(
        future: transportProvider.loadTransports(), // Загружаем транспорт
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки транспорта: ${snapshot.error}'));
          }

          return ListView.builder(
            itemCount: transportProvider.transports.length,
            itemBuilder: (context, index) {
              Transport transport = transportProvider.transports[index];
              return ListTile(
                title: Text("${transport.model}"),
                subtitle: Text("License Plate: ${transport.licensePlate}"),
                trailing: Switch(
                  value: transport.availability,
                  onChanged: (bool newValue) {
                    transportProvider.updateTransport(
                      Transport(
                        id: transport.id,
                        model: transport.model,
                        licensePlate: transport.licensePlate,
                        availability: newValue,
                      ),
                    );
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Transport"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Model"),
              ),
              TextField(
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
                    model: "New Model", // Замените на реальные данные
                    licensePlate: "New License Plate", // Замените на реальные данные
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