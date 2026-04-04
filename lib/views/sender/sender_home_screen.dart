import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/shipment_view_model.dart';
import '../../widgets/user_menu_button.dart';
import 'sender_post_create_screen.dart';

class SenderHomeScreen extends StatelessWidget {
  const SenderHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ShipmentViewModel>(context);

    print('[SENDER_SCREEN] travelerPosts=${vm.travelerPosts.length}');
    for (final p in vm.travelerPosts) {
      print('[SENDER_SCREEN_ITEM] id=${p.id} ${p.origin} -> ${p.destination}');
    }

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
          const UserMenuButton(),
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
