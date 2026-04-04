import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../viewmodels/shipment_view_model.dart';
import 'traveler_post_create_screen.dart';

class TravelerHomeScreen extends StatelessWidget {
  const TravelerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ShipmentViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sender Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_road),
            tooltip: 'Add where you want to go',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TravelerPostCreateScreen(),
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
      body: vm.senderPosts.isEmpty
          ? const Center(child: Text('No sender posts yet'))
          : ListView.builder(
              itemCount: vm.senderPosts.length,
              itemBuilder: (context, index) {
                final item = vm.senderPosts[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: Text('${item.origin} ➜ ${item.destination}'),
                    subtitle: const Text('Sender is traveling this route'),
                  ),
                );
              },
            ),
    );
  }
}
