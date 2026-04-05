import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../viewmodels/shipment_view_model.dart';
import 'traveler_post_create_screen.dart';

class TravelerHomeScreen extends StatefulWidget {
  const TravelerHomeScreen({super.key});

  @override
  State<TravelerHomeScreen> createState() => _TravelerHomeScreenState();
}

class _TravelerHomeScreenState extends State<TravelerHomeScreen> {
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

  Future<void> _showExitDialog() async {
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

    if (result == true && mounted) {
      SystemNavigator.pop();
    }
  }

  Future<void> _onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) {
      return;
    }
    await _showExitDialog();
  }

  Widget _buildSearchTab(ShipmentViewModel vm) {
    if (vm.senderPosts.isEmpty) {
      return const Center(child: Text('No sender posts yet'));
    }

    return ListView.builder(
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
              'Create a travel request and start matching with senders.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_road),
              label: const Text('Add travel request'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TravelerPostCreateScreen(),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ShipmentViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
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
