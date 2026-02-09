import 'package:flutter/material.dart';

class ReceiptScanScreen extends StatelessWidget {
  const ReceiptScanScreen({super.key});

  static const routeName = '/receipt-scan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt scan')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Receipt scanning', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Scan or upload receipts to auto-fill expenses. This feature is coming soon.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.document_scanner_outlined),
                label: const Text('Scan receipt (coming soon)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
