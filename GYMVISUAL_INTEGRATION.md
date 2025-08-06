# GymVisual Integration Guide

This guide explains how to integrate and use GymVisual exercises in your workout app.

## Overview

GymVisual.com is a comprehensive resource for exercise illustrations, anatomical references, and fitness content. This integration allows you to:

- Import exercises from GymVisual into your app
- Display exercise data with proper attribution
- Filter and search exercises by various criteria
- Manage exercise metadata and difficulty levels

## Features

### 1. Exercise Import
- Import exercises from GymVisual with full metadata
- Batch import functionality for multiple exercises
- Automatic categorization and tagging

### 2. Exercise Management
- Search exercises by name and description
- Filter by difficulty level (Beginner, Intermediate, Advanced)
- Filter by equipment requirements
- Real-time updates from Firestore

### 3. Data Structure
Each GymVisual exercise includes:
- **Basic Info**: ID, name, description, category
- **Muscle Groups**: Targeted muscle groups
- **Instructions**: Step-by-step exercise instructions
- **Equipment**: Required equipment (if any)
- **Difficulty**: Beginner, Intermediate, or Advanced
- **Source**: Attribution to GymVisual.com
- **Metadata**: Import date, additional data

## Usage

### Accessing GymVisual Exercises

1. **Navigate to Profile Tab**
   - Open the app and go to the Profile tab
   - Scroll down to "Other" section
   - Tap "GymVisual Exercises"

2. **Import Exercises**
   - Tap "Import GymVisual Exercises" button
   - Wait for the import to complete
   - Exercises will be stored in Firestore

3. **Browse and Filter**
   - Use the search bar to find specific exercises
   - Filter by difficulty level
   - Filter by equipment requirements
   - View exercise details by tapping on an exercise

### Available Exercises

The current integration includes these GymVisual exercises:

| ID | Name | Category | Difficulty | Equipment |
|----|------|----------|------------|-----------|
| 186012 | Hyperextension (VERSION 2) | Strength | Intermediate | Hyperextension Bench |
| 2043 | Rectus Abdominis | Anatomy | Beginner | None |
| 1024 | Side Relaxed Pose | Reference | Beginner | None |
| 1250 | Weighted Crunch (behind head) | Strength | Advanced | Incline Bench, Weight |
| 1251 | Weighted Crunch | Strength | Intermediate | Weight |

## Technical Implementation

### Services

#### GymVisualService
```dart
// Import exercises
await gymVisualService.importGymVisualExercises();

// Get all GymVisual exercises
List<Exercise> exercises = await gymVisualService.getGymVisualExercises();

// Search by difficulty
List<Exercise> beginnerExercises = await gymVisualService.getExercisesByDifficulty('Beginner');

// Search by equipment
List<Exercise> noEquipmentExercises = await gymVisualService.getExercisesByEquipment('None');
```

#### Models

#### GymVisualExercise
Extended exercise model with additional metadata:
```dart
class GymVisualExercise extends Exercise {
  final String source;
  final String equipment;
  final String difficulty;
  final String? gymVisualId;
  final DateTime? importedAt;
  final Map<String, dynamic>? additionalData;
}
```

### Firestore Structure

Exercises are stored in the `exercises` collection with the following structure:

```json
{
  "id": "186012",
  "name": "Hyperextension (VERSION 2)",
  "description": "Lower back exercise performed on a hyperextension bench",
  "category": "Strength",
  "muscleGroups": ["Lower Back", "Glutes", "Hamstrings"],
  "instructions": "Step-by-step instructions...",
  "imageUrl": "https://gymvisual.com/exercises/hyperextension-v2",
  "source": "GymVisual",
  "equipment": "Hyperextension Bench",
  "difficulty": "Intermediate",
  "importedAt": "2024-01-01T00:00:00Z"
}
```

## Adding New Exercises

### 1. Update GymVisualService
Add new exercises to the `gymVisualExercises` map:

```dart
static const Map<String, dynamic> gymVisualExercises = {
  "NEW_ID": {
    "id": "NEW_ID",
    "name": "Exercise Name",
    "description": "Exercise description",
    "category": "Category",
    "muscleGroups": ["Muscle1", "Muscle2"],
    "instructions": "Step-by-step instructions",
    "imageUrl": "https://gymvisual.com/exercises/exercise-url",
    "equipment": "Equipment needed",
    "difficulty": "Beginner/Intermediate/Advanced",
    "source": "GymVisual"
  },
  // ... existing exercises
};
```

### 2. Import New Exercises
Run the import function to add new exercises to Firestore:

```dart
await gymVisualService.importGymVisualExercises();
```

## Customization

### Filtering Options
You can customize the filtering options by modifying the lists in `GymVisualExercisesScreen`:

```dart
final List<String> _difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];
final List<String> _equipment = ['All', 'None', 'Weight', 'Hyperextension Bench', 'Incline Bench, Weight'];
```

### UI Customization
The exercise cards can be customized by modifying the `ListView.builder` in the screen.

### Data Validation
Add validation for exercise data before importing:

```dart
// Example validation
if (exerciseData['name'] == null || exerciseData['name'].isEmpty) {
  throw Exception('Exercise name is required');
}
```

## Best Practices

### 1. Attribution
Always include proper attribution to GymVisual.com:
- Display "Source: GymVisual.com" in the UI
- Include source information in the data structure
- Respect GymVisual's terms of service

### 2. Data Management
- Regularly update exercise data
- Validate imported data
- Handle import errors gracefully
- Provide user feedback during import process

### 3. Performance
- Use pagination for large exercise lists
- Implement caching for frequently accessed data
- Optimize search and filter operations

### 4. User Experience
- Show loading indicators during import
- Provide clear error messages
- Allow users to cancel import operations
- Save user preferences for filters

## Troubleshooting

### Common Issues

1. **Import Fails**
   - Check Firebase connection
   - Verify Firestore permissions
   - Ensure exercise data is valid

2. **Exercises Not Loading**
   - Check if exercises exist in Firestore
   - Verify filter criteria
   - Check network connectivity

3. **Search Not Working**
   - Verify search query format
   - Check case sensitivity
   - Ensure data is properly indexed

### Debug Information

Enable debug logging to troubleshoot issues:

```dart
// Add debug prints
print('Importing ${gymVisualExercises.length} exercises');
print('Exercise data: $exerciseData');
```

## Future Enhancements

### Planned Features
- Video integration from GymVisual
- Exercise variations and alternatives
- User-generated exercise ratings
- Integration with workout plans
- Offline exercise database

### API Integration
Consider implementing a direct API integration with GymVisual for real-time data updates.

## Support

For issues related to GymVisual integration:
1. Check the Firebase console for errors
2. Verify exercise data structure
3. Test import functionality
4. Review Firestore security rules

## Legal Considerations

- Ensure compliance with GymVisual's terms of service
- Include proper attribution
- Respect copyright and licensing requirements
- Consider implementing rate limiting for API calls 