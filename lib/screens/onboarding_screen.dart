import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  final _savingsController = TextEditingController();
  bool _isStudent = true;
  bool _consent = false;
  String _currency = 'USD';

  @override
  void dispose() {
    _ageController.dispose();
    _incomeController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final profile = UserProfile(
      age: int.parse(_ageController.text),
      isStudent: _isStudent,
      monthlyIncome: double.parse(_incomeController.text),
      currency: _currency,
      savingsGoal: double.parse(_savingsController.text),
    );
    final appState = context.read<AppState>();
    appState.saveProfile(profile);
    appState.updateConsent(_consent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Finance for Students',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Track money, get smart suggestions, save without stress.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age'),
                        validator: (value) => value == null || value.isEmpty ? 'Enter age' : null,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        value: _isStudent,
                        onChanged: (value) => setState(() => _isStudent = value),
                        title: const Text('I am currently a student'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _incomeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Monthly income'),
                        validator: (value) => value == null || value.isEmpty ? 'Enter income' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _currency,
                        items: const [
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                          DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                          DropdownMenuItem(value: 'INR', child: Text('INR')),
                        ],
                        onChanged: (value) => setState(() => _currency = value ?? 'USD'),
                        decoration: const InputDecoration(labelText: 'Currency'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _savingsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Monthly savings goal'),
                        validator: (value) => value == null || value.isEmpty ? 'Enter goal' : null,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        value: _consent,
                        onChanged: (value) => setState(() => _consent = value),
                        title: const Text('Allow AI analysis to offer suggestions'),
                        subtitle: const Text('You can change this later in Insights.'),
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(label: 'Get started', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
