import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/shipment_view_model.dart';
import '../../widgets/user_menu_button.dart';
import 'traveler_post_create_screen.dart';

class TravelerHomeScreen extends StatelessWidget {
  const TravelerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ShipmentViewModel>(context);

    for (var post in vm.travelerPosts) {
      print('Origin: ${post.origin}, Destination: ${post.destination}');
    }

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
          const UserMenuButton(),
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
