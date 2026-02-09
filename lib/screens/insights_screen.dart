import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/ai_insight_card.dart';
import 'reports_screen.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  static const routeName = '/insights';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('AI Insights')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SwitchListTile.adaptive(
              value: appState.aiConsent,
              onChanged: (value) => appState.updateConsent(value),
              title: const Text('Allow AI analysis'),
              subtitle: const Text('We only analyze when you opt in.'),
            ),
            SwitchListTile.adaptive(
              value: appState.alertsEnabled,
              onChanged: (value) => appState.updateAlerts(value),
              title: const Text('Budget alerts'),
              subtitle: const Text('Get gentle notifications on overspending.'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: appState.signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Connect Google account'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: appState.aiConsent ? appState.requestAiInsight : null,
              icon: const Icon(Icons.auto_graph_outlined),
              label: const Text('Generate insights'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: appState.isSignedIn
                  ? () async {
                      await appState.syncNow();
                    }
                  : null,
              icon: const Icon(Icons.cloud_sync_outlined),
              label: const Text('Sync now'),
            ),
            if (appState.lastSyncedAt.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Last synced: ${appState.lastSyncedAt}'),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(ReportsScreen.routeName),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Open reports'),
            ),
            const SizedBox(height: 20),
            AiInsightCard(title: 'Financial Summary', body: appState.insight.summary),
            const SizedBox(height: 12),
            AiInsightCard(title: 'Spending Analysis', body: appState.insight.analysis),
            const SizedBox(height: 12),
            AiInsightCard(title: 'Predictions', body: appState.insight.predictions),
            const SizedBox(height: 12),
            if (appState.insight.observations.isNotEmpty)
              AiInsightCard(
                title: 'Key Observations',
                body: appState.insight.observations.join('\n'),
              ),
            const SizedBox(height: 12),
            if (appState.insight.suggestions.isNotEmpty)
              AiInsightCard(
                title: 'Actionable Suggestions',
                body: appState.insight.suggestions.join('\n'),
              ),
            const SizedBox(height: 12),
            if (appState.insight.educationTips.isNotEmpty)
              AiInsightCard(
                title: 'Financial Education Tips',
                body: appState.insight.educationTips.join('\n'),
              ),
          ],
        ),
      ),
    );
  }
}
