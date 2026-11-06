import 'package:flutter_test/flutter_test.dart';
import 'package:arttrace/app/data/sample_data/sample_categories.dart';
import 'package:arttrace/app/data/sample_data/sample_drawings.dart';
import 'package:arttrace/app/data/sample_data/sample_tutorials.dart';
import 'package:arttrace/app/data/models/drawing_model.dart';

void main() {
  group('ArtTrace Data and Repository Tests', () {
    test('Categories list contains all 10 required categories', () {
      final categories = SampleCategories.categories;
      expect(categories.length, 10);

      final categoryIds = categories.map((c) => c.id).toSet();
      expect(categoryIds.contains('anime'), isTrue);
      expect(categoryIds.contains('cartoon'), isTrue);
      expect(categoryIds.contains('animals'), isTrue);
      expect(categoryIds.contains('flowers'), isTrue);
      expect(categoryIds.contains('nature'), isTrue);
      expect(categoryIds.contains('vehicles'), isTrue);
      expect(categoryIds.contains('superheroes'), isTrue);
      expect(categoryIds.contains('cute'), isTrue);
      expect(categoryIds.contains('beginner'), isTrue);
      expect(categoryIds.contains('advanced'), isTrue);
    });

    test('Drawings contain valid models and assets', () {
      final drawings = SampleDrawings.drawings;
      expect(drawings.isNotEmpty, isTrue);

      for (final drawing in drawings) {
        expect(drawing.id.isNotEmpty, isTrue);
        expect(drawing.title.isNotEmpty, isTrue);
        expect(drawing.assetPath.isNotEmpty, isTrue);
        expect(drawing.difficulty, isA<DrawingDifficulty>());
      }
    });

    test('Step-by-step tutorials are correctly configured', () {
      final tutorials = SampleTutorials.tutorials;
      expect(tutorials.isNotEmpty, isTrue);

      final tut = tutorials.first;
      expect(tut.steps.length, greaterThanOrEqualTo(4));
      expect(tut.steps.first.stepNumber, 1);
      expect(tut.steps.first.instruction.isNotEmpty, isTrue);
      expect(tut.steps.first.imageAsset.isNotEmpty, isTrue);
    });
  });
}
