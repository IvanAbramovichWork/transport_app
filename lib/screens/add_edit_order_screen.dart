import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/transport_provider.dart';
import '../models/order.dart';
import '../models/transport.dart';

class AddEditOrderScreen extends StatefulWidget {
  final Order? order;

  const AddEditOrderScreen({Key? key, this.order}) : super(key: key);

  @override
  _AddEditOrderScreenState createState() => _AddEditOrderScreenState();
}

class _AddEditOrderScreenState extends State<AddEditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  OrderStatus? _status;
  int? _selectedTransportId;
  int? _userId;

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _selectedDate = widget.order!.date;
      _status = widget.order!.status;
      _selectedTransportId = widget.order!.transportId;
      _userId = widget.order!.userId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transportProvider = Provider.of<TransportProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final isEditing = widget.order != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Order' : 'Add Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(labelText: 'Date'),
                controller: TextEditingController(
                  text: _selectedDate != null ? _selectedDate!.toIso8601String().split('T')[0] : '',
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              ),
              DropdownButtonFormField<OrderStatus>(
                value: _status,
                decoration: InputDecoration(labelText: 'Status'),
                items: OrderStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value),
              ),
              DropdownButtonFormField<int>(
                value: _selectedTransportId,
                decoration: InputDecoration(labelText: 'Transport'),
                items: transportProvider.transports.map((Transport transport) {
                  return DropdownMenuItem(
                    value: transport.id,
                    child: Text(transport.licensePlate),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTransportId = value),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedDate != null && _status != null && _selectedTransportId != null) {
                    final newOrder = Order(
                      id: isEditing ? widget.order!.id : 0,
                      userId: _userId ?? 0,
                      transportId: _selectedTransportId!,
                      status: _status!,
                      date: _selectedDate!,
                    );
                    if (isEditing) {
                      orderProvider.updateOrder(newOrder);
                    } else {
                      orderProvider.addOrder(newOrder);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Update Order' : 'Add Order'),
              ),
              if (isEditing) ...[
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    print("aaaaaaaaaaaaaa");

                    orderProvider.deleteOrder(widget.order!.id, _userId ?? 0, true);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Delete Order'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
