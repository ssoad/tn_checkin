import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/check_in_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CreateCheckInScreen extends ConsumerStatefulWidget {
  const CreateCheckInScreen({super.key});

  @override
  ConsumerState<CreateCheckInScreen> createState() => _CreateCheckInScreenState();
}

class _CreateCheckInScreenState extends ConsumerState<CreateCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _radiusController = TextEditingController(text: '50');

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Check-in Point'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter check-in point title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Radius field
                TextFormField(
                  controller: _radiusController,
                  decoration: const InputDecoration(
                    labelText: 'Check-in Radius (meters)',
                    hintText: 'Enter radius in meters',
                    border: OutlineInputBorder(),
                    suffixText: 'meters',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a radius';
                    }
                    final radius = double.tryParse(value);
                    if (radius == null || radius <= 0) {
                      return 'Please enter a valid radius';
                    }
                    if (radius > 1000) {
                      return 'Radius cannot be more than 1000 meters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Info card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'The check-in point will be created at your current location',
                            style: TextStyle(color: Colors.blue.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Create button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: checkInState.isLoading ? null : _createCheckInPoint,
                    child: checkInState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Check-in Point'),
                  ),
                ),

                const SizedBox(height: 16),

                // Error message
                if (checkInState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            checkInState.error!,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createCheckInPoint() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(checkInProvider.notifier).createCheckInPoint(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          createdBy: userId,
          radiusInMeters: double.parse(_radiusController.text),
        );

    if (mounted && ref.read(checkInProvider).activeCheckInPoint != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in point created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
