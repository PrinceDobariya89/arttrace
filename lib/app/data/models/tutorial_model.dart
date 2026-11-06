class TutorialStep {
  final int stepNumber;
  final String title;
  final String instruction;
  final String tip;
  final String imageAsset;

  const TutorialStep({
    required this.stepNumber,
    required this.title,
    required this.instruction,
    required this.tip,
    required this.imageAsset,
  });

  Map<String, dynamic> toJson() => {
    'stepNumber': stepNumber,
    'title': title,
    'instruction': instruction,
    'tip': tip,
    'imageAsset': imageAsset,
  };

  factory TutorialStep.fromJson(Map<String, dynamic> json) {
    return TutorialStep(
      stepNumber: json['stepNumber'] as int,
      title: json['title'] as String,
      instruction: json['instruction'] as String,
      tip: json['tip'] as String,
      imageAsset: json['imageAsset'] as String,
    );
  }
}

class DrawingTutorial {
  final String id;
  final String drawingId;
  final String title;
  final String category;
  final String difficulty;
  final String coverAsset;
  final List<TutorialStep> steps;

  const DrawingTutorial({
    required this.id,
    required this.drawingId,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.coverAsset,
    required this.steps,
  });
}

