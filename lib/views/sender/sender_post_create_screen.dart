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
  int _budget = 150;
  DateTime? _pickupDate;
  DateTime? _deliveryDate;
  bool _deliveryEnabled = false;
  int _seatsNeeded = 1;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickPickupDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _pickupDate = picked;
        if (_deliveryDate != null && _deliveryDate!.isBefore(picked)) {
          _deliveryDate = null;
        }
      });
    }
  }

  Future<void> _pickDeliveryDate() async {
    final now = DateTime.now();
    final initialDate = _deliveryDate ?? _pickupDate ?? now;
    final firstDate = _pickupDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _submit() async {
    if (_pickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a pickup date.')),
      );
      return;
    }
    if (_deliveryEnabled && _deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a delivery date or disable delivery.')),
      );
      return;
    }
    if (_deliveryEnabled && _deliveryDate!.isBefore(_pickupDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery date must be after pickup date.')),
      );
      return;
    }

    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final shipmentVm = Provider.of<ShipmentViewModel>(context, listen: false);

    final uid = authVm.firebaseUser?.uid;
    if (uid == null) return;

    await shipmentVm.createSenderPost(
      senderId: uid,
      origin: _originController.text.trim(),
      destination: _destinationController.text.trim(),
      budget: _budget,
      pickupDate: _pickupDate!,
      deliveryDate: _deliveryEnabled ? _deliveryDate : null,
      seatsNeeded: _seatsNeeded,
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
      appBar: AppBar(title: const Text('Add Shipment Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _originController,
                  decoration: const InputDecoration(labelText: 'Pickup From'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter pickup location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(labelText: 'Deliver To'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter delivery destination';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget: \$$_budget', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Slider(
                      value: _budget.toDouble(),
                      min: 0,
                      max: 2000,
                      divisions: 40,
                      label: '\$$_budget',
                      onChanged: (value) {
                        setState(() {
                          _budget = value.round();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _pickPickupDate,
                  child: Text(_pickupDate == null
                      ? 'Select pickup date'
                      : 'Pickup: ${_formatDate(_pickupDate!)}'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Specific delivery date?'),
                  value: _deliveryEnabled,
                  onChanged: (value) {
                    setState(() {
                      _deliveryEnabled = value;
                      if (!value) {
                        _deliveryDate = null;
                      }
                    });
                  },
                ),
                if (_deliveryEnabled) ...[
                  ElevatedButton(
                    onPressed: _pickupDate == null ? null : _pickDeliveryDate,
                    child: Text(_deliveryDate == null
                        ? 'Select delivery date'
                        : 'Delivery: ${_formatDate(_deliveryDate!)}'),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 24),
                DropdownButtonFormField<int>(
                  initialValue: _seatsNeeded,
                  decoration: const InputDecoration(labelText: 'Seats needed'),
                  items: List.generate(10, (index) => index + 1)
                      .map((seats) => DropdownMenuItem(
                            value: seats,
                            child: Text('$seats seat${seats > 1 ? 's' : ''}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _seatsNeeded = value ?? 1;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Post Shipment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
