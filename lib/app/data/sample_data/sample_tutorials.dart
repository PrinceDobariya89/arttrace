import '../models/tutorial_model.dart';

class SampleTutorials {
  static const List<DrawingTutorial> tutorials = [
    DrawingTutorial(
      id: 'tutorial_anime_eye',
      drawingId: 'anime_girl_eye_01',
      title: 'How to Draw Sparkling Anime Eyes',
      category: 'Anime',
      difficulty: 'Beginner',
      coverAsset: 'assets/drawings/tutorial_eye_step4.png',
      steps: [
        TutorialStep(
          stepNumber: 1,
          title: 'Step 1: Guideline Arcs & Circle',
          instruction: 'Lightly sketch a circle and crosshairs for alignment. Then curve a thick upper eyelid sweeping slightly downward at the outer corner.',
          tip: 'Keep your pencil pressure very light in this step so lines can be traced effortlessly without grooving the paper.',
          imageAsset: 'assets/drawings/tutorial_eye_step1.png',
        ),
        TutorialStep(
          stepNumber: 2,
          title: 'Step 2: Iris Oval & Lower Lid',
          instruction: 'Draw an elongated oval beneath the upper lid. Curve a gentle lower eyelid line underneath to frame the eye width.',
          tip: 'Anime irises are usually taller than they are wide. Leave a tiny gap between the bottom of the iris and lower lid for a youthful look.',
          imageAsset: 'assets/drawings/tutorial_eye_step2.png',
        ),
        TutorialStep(
          stepNumber: 3,
          title: 'Step 3: Pupil & Multiple Highlights',
          instruction: 'Place a darker oval for the pupil in the upper center. Draw 2-3 circular highlight shapes that will remain pure white when shading.',
          tip: 'Position highlights in the direction of your imaginary light source (top-left) to make the character look lively and awake.',
          imageAsset: 'assets/drawings/tutorial_eye_step3.png',
        ),
        TutorialStep(
          stepNumber: 4,
          title: 'Step 4: Final Inking & Eyelash Detail',
          instruction: 'Darken the top eyelid lash line with bold strokes. Add side flick eyelashes, the upper crease fold, and a smooth eyebrow above.',
          tip: 'Use a fine-liner or darker pencil (2B/4B) to emphasize the outer corners for maximum anime appeal.',
          imageAsset: 'assets/drawings/tutorial_eye_step4.png',
        ),
      ],
    ),
  ];
}

