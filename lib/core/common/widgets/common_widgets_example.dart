// Example usage of Common Widgets Library
// This file demonstrates how to use all the common widgets created

import 'package:flutter/material.dart';
import 'package:tn_checkin/core/common/widgets/widgets.dart';

class CommonWidgetsExample extends StatefulWidget {
  const CommonWidgetsExample({super.key});

  @override
  State<CommonWidgetsExample> createState() => _CommonWidgetsExampleState();
}

class _CommonWidgetsExampleState extends State<CommonWidgetsExample> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Common Widgets Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Fields Section
            Text('Text Fields', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            
            CommonTextField(
              controller: _nameController,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CommonTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: const Icon(Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CommonPasswordField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password is required';
                if (value!.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            // Buttons Section
            Text('Buttons', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            
            CommonButton.filled(
              text: 'Primary Button',
              onPressed: _isLoading ? null : _simulateLoading,
              isLoading: _isLoading,
              fullWidth: true,
            ),
            const SizedBox(height: 12),
            
            CommonButton.outlined(
              text: 'Secondary Button',
              icon: const Icon(Icons.edit),
              onPressed: () => _showSnackBar('Outlined button pressed'),
            ),
            const SizedBox(height: 12),
            
            CommonButton.text(
              text: 'Text Button',
              onPressed: () => _showSnackBar('Text button pressed'),
            ),
            const SizedBox(height: 12),
            
            CommonButton.tonal(
              text: 'Tonal Button',
              icon: const Icon(Icons.settings),
              onPressed: () => _showSnackBar('Tonal button pressed'),
              fullWidth: true,
            ),
            
            const SizedBox(height: 32),
            
            // Loading Indicators Section
            Text('Loading Indicators', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CommonLoading.small(),
                CommonLoading(),
                CommonLoading.large(),
              ],
            ),
            const SizedBox(height: 16),
            
            const CommonLinearLoading.determinate(value: 0.7),
            const SizedBox(height: 8),
            const CommonLinearLoading.indeterminate(),
            
            const SizedBox(height: 16),
            const CommonSkeletonLoading.text(width: 200),
            const SizedBox(height: 8),
            const CommonSkeletonLoading.card(height: 80),
            
            const SizedBox(height: 32),
            
            // Cards Section
            Text('Cards', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            
            CommonCard.elevated(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Elevated Card', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('This is an elevated card with shadow elevation.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            CommonCard.filled(
              onTap: () => _showSnackBar('Filled card tapped'),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filled Card', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('This is a filled tonal card with tap interaction.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            CommonCard.outlined(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outlined Card', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('This is an outlined card with border.'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info Cards
            CommonInfoCard(
              icon: const Icon(Icons.person),
              title: 'User Profile',
              description: 'Manage your account settings and preferences',
              onTap: () => _showSnackBar('Profile card tapped'),
            ),
            const SizedBox(height: 12),
            
            CommonInfoCard.navigation(
              icon: const Icon(Icons.settings),
              title: 'Settings',
              description: 'Configure app settings and notifications',
              onTap: () => _showSnackBar('Settings card tapped'),
            ),
            
            const SizedBox(height: 16),
            
            // Status Cards
            const CommonStatusCard.success(
              status: 'Success',
              description: 'Operation completed successfully',
            ),
            const SizedBox(height: 8),
            
            const CommonStatusCard.error(
              status: 'Error',
              description: 'Something went wrong',
            ),
            const SizedBox(height: 8),
            
            const CommonStatusCard.warning(
              status: 'Warning',
              description: 'Please check your input',
              badge: true,
            ),
            const SizedBox(height: 8),
            
            const CommonStatusCard.info(
              status: 'Info',
              description: 'Additional information available',
              badge: true,
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: const CommonFloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: 'Add Item',
      ),
    );
  }

  void _simulateLoading() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
    });
    
    _showSnackBar('Loading completed!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
