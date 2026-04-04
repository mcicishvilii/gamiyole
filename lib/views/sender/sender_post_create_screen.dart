import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../viewmodels/shipment_view_model.dart';

class SenderPostCreateScreen extends StatefulWidget {
  const SenderPostCreateScreen({super.key});

  @override
  State<SenderPostCreateScreen> createState() => _SenderPostCreateScreenState();
}

class _SenderPostCreateScreenState extends State<SenderPostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final shipmentVm = Provider.of<ShipmentViewModel>(context, listen: false);

    final uid = authVm.firebaseUser?.uid;
    if (uid == null) return;

    await shipmentVm.createSenderPost(
      senderId: uid,
      origin: _originController.text.trim(),
      destination: _destinationController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sender post created successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Where You Are Going')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(labelText: 'From'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your starting city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: 'To'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Post My Route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
