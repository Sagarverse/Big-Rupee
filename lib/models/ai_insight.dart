class AiInsight {
  AiInsight({
    required this.summary,
    required this.analysis,
    required this.observations,
    required this.predictions,
    required this.suggestions,
    required this.educationTips,
  });

  final String summary;
  final String analysis;
  final List<String> observations;
  final String predictions;
  final List<String> suggestions;
  final List<String> educationTips;

  factory AiInsight.empty() => AiInsight(
        summary: 'No insights yet. Connect to AI when you are ready.',
        analysis: 'Add a few transactions to unlock better insights.',
        observations: const [],
        predictions: 'Build a track record to see predictions.',
        suggestions: const [],
        educationTips: const [],
      );
}
