import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/shipment_view_model.dart';
import '../../viewmodels/auth/auth_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SenderHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Shipments"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Logout"),
                value: "logout",
              ),
            ],
            onSelected: (value) {
              if (value == "logout") {
                Provider.of<AuthViewModel>(context, listen: false).logout();
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_travel,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 24),
              Text(
                "Sender Dashboard",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "Post your shipments and connect with trustworthy travelers.",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Provider.of<ShipmentViewModel>(context, listen: false)
                      .createTestShipment();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Shipment created!")),
                  );
                },
                icon: Icon(Icons.add),
                label: Text("Create New Shipment"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
