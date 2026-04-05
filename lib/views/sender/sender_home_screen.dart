import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../viewmodels/shipment_view_model.dart';
import 'sender_post_create_screen.dart';

class SenderHomeScreen extends StatefulWidget {
  const SenderHomeScreen({super.key});

  @override
  State<SenderHomeScreen> createState() => _SenderHomeScreenState();
}

class _SenderHomeScreenState extends State<SenderHomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Search',
    'Publish',
    'Your Rides',
    'Inbox',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave App?'),
          content: const Text('Are you sure you want to leave the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Widget _buildSearchTab(ShipmentViewModel vm) {
    if (vm.travelerPosts.isEmpty) {
      return const Center(child: Text('No traveler posts yet'));
    }

    return ListView.builder(
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
    );
  }

  Widget _buildPublishTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create a sender post and start matching with travelers.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add sender post'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SenderPostCreateScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderConstruction(String label) {
    return Center(
      child: Text(
        '$label is under construction',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProfileTab(AuthViewModel authVm) {
    final user = authVm.appUser;
    final email = user?.email ?? authVm.firebaseUser?.email ?? 'Unknown user';
    final role = user?.role ?? 'member';
    final firstLetter = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    final colorSeed = user?.uid ?? email;
    final avatarColor = Colors
        .primaries[colorSeed.hashCode.abs() % Colors.primaries.length]
        .shade400;

    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: avatarColor,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                role,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () {
                    authVm.logout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ShipmentViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);

    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: AppBar(title: Text(_titles[_selectedIndex])),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildSearchTab(vm),
            _buildPublishTab(context),
            _buildUnderConstruction('Your Rides'),
            _buildUnderConstruction('Inbox'),
            _buildProfileTab(authVm),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.publish),
              label: 'Publish',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Your Rides',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Inbox'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
