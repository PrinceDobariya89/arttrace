import '../models/tutorial_model.dart';
import '../sample_data/sample_tutorials.dart';

class TutorialRepository {
  List<DrawingTutorial> getAllTutorials() {
    return List.from(SampleTutorials.tutorials);
  }

  DrawingTutorial? getTutorialById(String id) {
    try {
      return SampleTutorials.tutorials.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  DrawingTutorial? getTutorialForDrawing(String drawingId) {
    try {
      return SampleTutorials.tutorials.firstWhere((t) => t.drawingId == drawingId);
    } catch (_) {
      return null;
    }
  }
}

