import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/shipment_view_model.dart';

class ShipmentFeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ShipmentViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby Requests"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => vm.createTestShipment(),
          ),
        ],
      ),
      body: vm.shipments.isEmpty
          ? Center(child: Text("No requests found"))
          : ListView.builder(
              itemCount: vm.shipments.length,
              itemBuilder: (context, index) {
                final item = vm.shipments[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("${item.origin} ➔ ${item.destination}"),
                    subtitle: Text("Budget: \$${item.budget}"),
                    trailing: ElevatedButton(
                      onPressed: () => _showBidDialog(context, vm, item.id),
                      child: Text("Offer Price"),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showBidDialog(BuildContext context, ShipmentViewModel vm, String id) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Make an Offer"),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Enter your price"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(_controller.text);
              if (price != null) {
                vm.placeBid(
                  id,
                  "current_user_id",
                  price,
                ); // Replace with actual ID later
                Navigator.pop(context);
              }
            },
            child: Text("Send Offer"),
          ),
        ],
      ),
    );
  }
}
