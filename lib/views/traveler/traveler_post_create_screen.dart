import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../viewmodels/shipment_view_model.dart';

class TravelerPostCreateScreen extends StatefulWidget {
  const TravelerPostCreateScreen({super.key});

  @override
  State<TravelerPostCreateScreen> createState() =>
      _TravelerPostCreateScreenState();
}

class _TravelerPostCreateScreenState extends State<TravelerPostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  int _priceOffer = 150;
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _returnEnabled = false;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a departure date.')),
      );
      return;
    }
    if (_returnEnabled && _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a return date or disable return trip.')),
      );
      return;
    }
    if (_returnEnabled && _returnDate!.isBefore(_departureDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return date must be after departure date.')),
      );
      return;
    }

    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final shipmentVm = Provider.of<ShipmentViewModel>(context, listen: false);

    final uid = authVm.firebaseUser?.uid;
    if (uid == null) return;

    await shipmentVm.createTravelerPost(
      travelerId: uid,
      origin: _originController.text.trim(),
      destination: _destinationController.text.trim(),
      priceOffer: _priceOffer,
      departureDate: _departureDate!,
      returnDate: _returnEnabled ? _returnDate : null,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Traveler post created successfully.')),
    );
  }

  Future<void> _pickDepartureDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      });
    }
  }

  Future<void> _pickReturnDate() async {
    final now = DateTime.now();
    final initialDate = _returnDate ?? _departureDate ?? now;
    final firstDate = _departureDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Where You Want To Go')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Offer price: \\$_priceOffer', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Slider(
                      value: _priceOffer.toDouble(),
                      min: 0,
                      max: 2000,
                      divisions: 40,
                      label: '\\$_priceOffer',
                      onChanged: (value) {
                        setState(() {
                          _priceOffer = value.round();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _pickDepartureDate,
                  child: Text(_departureDate == null
                      ? 'Select departure date'
                      : 'Departure: ${_formatDate(_departureDate!)}'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Return trip?'),
                  value: _returnEnabled,
                  onChanged: (value) {
                    setState(() {
                      _returnEnabled = value;
                      if (!value) {
                        _returnDate = null;
                      }
                    });
                  },
                ),
                if (_returnEnabled) ...[
                  ElevatedButton(
                    onPressed: _departureDate == null ? null : _pickReturnDate,
                    child: Text(_returnDate == null
                        ? 'Select return date'
                        : 'Return: ${_formatDate(_returnDate!)}'),
                  ),
                  const SizedBox(height: 8),
                ],
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
      ),
    );
  }
}
