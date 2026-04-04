import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth/auth_view_model.dart';

class UserMenuButton extends StatelessWidget {
  const UserMenuButton({super.key});

  Color _stableColorFor(String seed) {
    final index = seed.hashCode.abs() % Colors.primaries.length;
    return Colors.primaries[index].shade400;
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.appUser;

    final email = user?.email ?? authVm.firebaseUser?.email ?? 'User';
    final role = user?.role ?? 'member';
    final firstLetter = email.isNotEmpty ? email[0].toUpperCase() : 'U';
    final colorSeed = user?.uid ?? email;
    final avatarColor = _stableColorFor(colorSeed);

    return PopupMenuButton<String>(
      tooltip: 'Account menu',
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(email, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                role,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          authVm.logout();
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: CircleAvatar(
        radius: 16,
        backgroundColor: avatarColor,
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
