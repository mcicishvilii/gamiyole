import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../viewmodels/shipment_view_model.dart';
import 'sender_post_create_screen.dart';

class SenderHomeScreen extends StatelessWidget {
  const SenderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ShipmentViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traveler Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            tooltip: 'Add where you are going',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SenderPostCreateScreen(),
                ),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<AuthViewModel>(context, listen: false).logout();
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: vm.travelerPosts.isEmpty
          ? const Center(child: Text('No traveler posts yet'))
          : ListView.builder(
              itemCount: vm.travelerPosts.length,
              itemBuilder: (context, index) {
                final item = vm.travelerPosts[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.person_pin_circle),
                    title: Text('${item.origin} ➜ ${item.destination}'),
                    subtitle: const Text('Traveler wants to go this route'),
                  ),
                );
              },
            ),
    );
  }
}
