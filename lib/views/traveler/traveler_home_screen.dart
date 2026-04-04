import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_view_model.dart';
import '../shipment_feed_screen.dart';

class TravelerHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Shipments"),
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
      body: ShipmentFeedScreen(),
    );
  }
}
