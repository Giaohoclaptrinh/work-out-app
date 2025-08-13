# Workout App

Flutter fitness app with workouts, custom routines, and integrations for meals and sleep. Focus areas updated: YouTube import → Custom Workouts per user, Cloud import/export, safer UI on small screens.

## Features

- **Workout tabs**: Workouts, Favorites, History, Custom
- **Import menu (AppBar)**:
  - Import from YouTube: save to `users/{uid}/customWorkouts`
  - Import from Cloud: fetch your `customWorkouts` and copy to local Custom tab
  - Delete on swipe: choose Remove locally or Delete from Cloud
- **Details screen**: video preview (WebView/YouTube), calories, minutes, level; hides Equipment if Bodyweight/None
- **JSON upload**: add core workouts from `assets/data/workouts.json` (with difficulty)

## Structure

```
lib/
  common/           # colors, helpers
  models/           # exercise.dart, workout.dart
  screens/          # workout_tracker_screen.dart, workout_detail_screen.dart, ...
  services/         # exercise_service.dart, workout_service.dart, ...
  widgets/          # reusable UI (WorkoutRow, DashboardCard, ...)
assets/
  data/workouts.json
```

## Getting Started

Prerequisites
- Flutter 3.32.x (stable)
- Xcode 16.4+ (iOS)

Run
```bash
cd work-out-app
flutter pub get
flutter run -d "iPhone 16"
```

## Data: JSON schema (assets/data/workouts.json)

```json
{
  "workouts": [
    {
      "title": "Push-Up",
      "muscleGroup": "Chest",
      "difficulty": "Beginner",
      "videoUrl": "https://www.youtube.com/watch?v=IODxDxX7oi4",
      "thumbnail": "https://img.youtube.com/vi/IODxDxX7oi4/hqdefault.jpg",
      "description": "...",
      "equipment": "Bodyweight"
    }
  ]
}
```

Notes
- difficulty supported: Beginner | Intermediate | Advanced (defaults to Intermediate if missing)
- YouTube thumbnails: use `https://img.youtube.com/vi/VIDEO_ID/hqdefault.jpg` (fallback `0.jpg` if needed)

## Import Workflows

- **YouTube**: Import → parse VIDEO_ID → store to `users/{uid}/customWorkouts` with fields (name, description, category, difficulty, duration, calories, equipment, image/thumbnailUrl, muscleGroups, isFavorite, type=custom, videoUrl, youtubeId, createdAt, updatedAt)
- **Cloud**: Import from Cloud → fetch your `customWorkouts` and copy to local Custom tab
- **Delete**: swipe in Custom tab → choose Remove locally or Delete from Cloud

## Troubleshooting

- Thumbnail 404: switch to `0.jpg` or ensure VIDEO_ID has no query params
- RenderFlex overflow: UI clamps text scale and buttons; if seen, reduce global font scale
- Git commands from root: use `git -C work-out-app <cmd>` or `cd work-out-app`

## License

GG
