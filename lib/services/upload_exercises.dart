import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:workout_app/models/exercise.dart';
import '../common/color_extension.dart';

/// Upload workouts from a bundled JSON file in assets/data/
/// jsonAssetPath example: 'assets/data/workouts.json'
Future<void> uploadExercisesFromJson(String jsonAssetPath) async {
  // Validate asset presence via AssetManifest (gives clearer error)
  try {
    final manifestRaw = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestRaw);
    if (!manifest.keys.contains(jsonAssetPath)) {
      throw Exception('Asset not found: ' + jsonAssetPath + '. Did you add it to pubspec.yaml and restart the app?');
    }
  } catch (_) {
    // ignore if manifest unavailable; loadString will still throw a clear error
  }

  // Load and parse JSON
  final raw = await rootBundle.loadString(jsonAssetPath);
  final Map<String, dynamic> payload = json.decode(raw) as Map<String, dynamic>;
  final List<dynamic> workouts = payload['workouts'] as List<dynamic>? ?? [];

  // Build list strictly from JSON; if empty, skip upload
  final List<Map<String, dynamic>> workoutExercises =
      workouts.cast<Map<String, dynamic>>();
  if (workoutExercises.isEmpty) {
    debugPrint('uploadExercisesFromJson: no workouts in ' + jsonAssetPath);
    return;
  }

  await _uploadWorkoutMaps(workoutExercises);
}

/// Upload workouts from a remote JSON URL (expects same schema as the assets JSON)
Future<void> uploadExercisesFromUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
    throw Exception('Invalid URL: $url');
  }

  final res = await http.get(uri);
  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception('Failed to fetch JSON: HTTP ${res.statusCode}');
  }

  final decoded = json.decode(res.body);
  List<Map<String, dynamic>> workoutExercises;
  if (decoded is Map<String, dynamic>) {
    final List<dynamic> list = decoded['workouts'] as List<dynamic>? ?? [];
    workoutExercises = list.cast<Map<String, dynamic>>();
  } else if (decoded is List) {
    // Also support a raw list form
    workoutExercises = decoded.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Unsupported JSON structure. Expected { "workouts": [...] } or a JSON array.');
  }

  if (workoutExercises.isEmpty) {
    throw Exception('No workouts found in the provided JSON.');
  }

  await _uploadWorkoutMaps(workoutExercises);
}

/// Import a single workout from a user-provided URL.
/// Supported sources:
///  - YouTube: extract videoId, build workout object with thumbnail
///  - Generic page: fetch and try to read OpenGraph (og:title, og:description, og:image)
Future<void> uploadWorkoutFromUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
    throw Exception('Invalid URL: $url');
  }

  // If YouTube URL, extract videoId and create a simple workout
  String? videoId = _tryExtractYouTubeId(url);
  String? title;
  String? description;
  String? imageUrl;

  if (videoId != null) {
    title = 'YouTube Workout';
    description = 'Imported from YouTube: ' + url;
    imageUrl = _generateYouTubeThumbnail(videoId);
  } else {
    // Fallback: fetch page and parse minimal OpenGraph metadata
    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to fetch page: HTTP ${res.statusCode}');
    }
    final html = res.body;
    String? ogTitle = _matchMetaContent(html, 'og:title');
    String? ogDesc = _matchMetaContent(html, 'og:description');
    String? ogImage = _matchMetaContent(html, 'og:image');
    title = ogTitle ?? 'Imported Workout';
    description = ogDesc ?? ('Imported from ' + url);
    imageUrl = ogImage;
  }

  final workoutMap = <String, dynamic>{
    'title': title ?? 'Imported Workout',
    'muscleGroup': 'General',
    'videoUrl': url,
    'thumbnail': imageUrl ?? '',
    'description': description ?? '',
    'equipment': '',
  };

  await _uploadWorkoutMaps([workoutMap]);
}

/// Parse a URL into a local Exercise object without writing to Firestore
Future<Exercise> parseExerciseFromUrl(String url) async {
  String? videoId = _tryExtractYouTubeId(url);
  String? title;
  String? description;
  String? imageUrl;

  if (videoId != null) {
    title = 'YouTube Workout';
    description = 'Imported from YouTube: ' + url;
    imageUrl = _generateYouTubeThumbnail(videoId);
  } else {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final html = res.body;
      title = _matchMetaContent(html, 'og:title') ?? 'Imported Workout';
      description = _matchMetaContent(html, 'og:description') ?? 'Imported from ' + url;
      imageUrl = _matchMetaContent(html, 'og:image');
    } else {
      title = 'Imported Workout';
      description = 'Imported from ' + url;
      imageUrl = '';
    }
  }

  return Exercise(
    id: 'local-' + DateTime.now().millisecondsSinceEpoch.toString(),
    name: title!,
    description: description ?? '',
    category: 'Custom',
    imageUrl: imageUrl,
    muscleGroups: const ['General'],
    instructions: description ?? '',
    duration: 20,
    calories: 60,
    steps: const [],
    type: 'workout',
  );
}

/// Normalize and upload list of workout maps to Firestore
Future<void> _uploadWorkoutMaps(List<Map<String, dynamic>> workoutExercises) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference exercisesCollection = firestore.collection('exercises');

  for (var exerciseData in workoutExercises) {
    // Accept flexible keys from JSON
    final String title = (exerciseData['title'] ?? exerciseData['name'] ?? '').toString();
    final String muscleGroup = (exerciseData['muscleGroup'] ?? (exerciseData['muscleGroups'] is List && (exerciseData['muscleGroups'] as List).isNotEmpty ? (exerciseData['muscleGroups'] as List).first : '')).toString();
    final String videoUrl = (exerciseData['videoUrl'] ?? '').toString();
    final String description = (exerciseData['description'] ?? '').toString();
    final String equipment = (exerciseData['equipment'] ?? '').toString();

    await exercisesCollection.add({
      'name': title, // Sử dụng 'name' thay vì 'title'
      'title': title, // Giữ lại title để tương thích
      'category': _mapMuscleGroupToCategory(muscleGroup),
      'muscleGroups': [muscleGroup], // Array of muscle groups
      'videoUrl': videoUrl,
      'imageUrl': _generateYouTubeThumbnail(
        _extractYouTubeVideoId(videoUrl),
      ), // Generate thumbnail từ video ID
      'image': _generateYouTubeThumbnail(
        _extractYouTubeVideoId(videoUrl),
      ), // Để tương thích
      'description': description,
      'equipment': equipment,
      'type': 'workout', // Đánh dấu đây là workout
      'duration': _estimateDuration(
        title,
      ), // Ước tính thời gian
      'calories': _estimateCalories(title), // Ước tính calories
      'difficulty': 'Beginner', // Mặc định là Beginner
      'isFavorite': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'source': 'Sample',
      'steps': _createWorkoutSteps({
        'title': title,
        'description': description,
        'thumbnail': exerciseData['thumbnail'] ?? '',
      }), // Tạo workout steps
      // ✅ TRƯỜNG WORKOUT - Lưu toàn bộ dữ liệu workout
      'workout': {
        'title': title,
        'muscleGroup': muscleGroup,
        'videoUrl': videoUrl,
        'thumbnail': _generateYouTubeThumbnail(
          _extractYouTubeVideoId(videoUrl),
        ),
        'description': description,
        'equipment': equipment,
        'duration': _estimateDuration(title),
        'calories': _estimateCalories(title),
        'difficulty': 'Beginner',
        'steps': _createWorkoutSteps({
          'title': title,
          'description': description,
          'thumbnail': exerciseData['thumbnail'] ?? '',
        }),
        'videoMetadata': {
          'platform': 'youtube',
          'videoId': _extractYouTubeVideoId(videoUrl),
          'embedUrl': videoUrl,
          'thumbnailUrl': _generateYouTubeThumbnail(
            _extractYouTubeVideoId(videoUrl),
          ),
          'canPlayInApp': true,
        },
      },
    });
  }
  debugPrint('All exercises uploaded to Firestore!');
}

/// Map muscle group to category for workout organization
String _mapMuscleGroupToCategory(String muscleGroup) {
  switch (muscleGroup.toLowerCase()) {
    case 'chest':
    case 'back':
    case 'shoulders':
    case 'biceps':
    case 'triceps':
      return 'Strength';
    case 'legs':
    case 'glutes':
      return 'Strength';
    case 'core':
      return 'Core';
    default:
      return 'Strength';
  }
}

/// Estimate workout duration based on exercise type
int _estimateDuration(String exerciseName) {
  final name = exerciseName.toLowerCase();
  if (name.contains('plank') || name.contains('bridge')) {
    return 10; // Hold exercises: 10 minutes
  } else if (name.contains('curl') || name.contains('extension')) {
    return 15; // Isolation exercises: 15 minutes
  } else {
    return 20; // Compound exercises: 20 minutes
  }
}

/// Estimate calories burned based on exercise type
int _estimateCalories(String exerciseName) {
  final name = exerciseName.toLowerCase();
  if (name.contains('plank') || name.contains('bridge')) {
    return 50; // Core exercises: 50 calories
  } else if (name.contains('squat') || name.contains('lunge')) {
    return 100; // Leg exercises: 100 calories
  } else if (name.contains('push-up') || name.contains('row')) {
    return 80; // Upper body compound: 80 calories
  } else {
    return 60; // Isolation exercises: 60 calories
  }
}

/// Extract YouTube video ID from URL
String _extractYouTubeVideoId(String videoUrl) {
  // Handle embed URLs like: https://www.youtube.com/embed/IODxDxX7oi4
  if (videoUrl.contains('/embed/')) {
    return videoUrl.split('/embed/')[1].split('?')[0];
  }
  // Handle watch URLs like: https://www.youtube.com/watch?v=IODxDxX7oi4
  if (videoUrl.contains('v=')) {
    return videoUrl.split('v=')[1].split('&')[0];
  }
  // Handle short URLs like: https://youtu.be/IODxDxX7oi4
  if (videoUrl.contains('youtu.be/')) {
    return videoUrl.split('youtu.be/')[1].split('?')[0];
  }
  // Fallback - return as is
  return videoUrl;
}

String? _tryExtractYouTubeId(String url) {
  try {
    return _extractYouTubeVideoId(url);
  } catch (_) {
    return null;
  }
}

/// Generate YouTube thumbnail URL from video ID
String _generateYouTubeThumbnail(String videoId) {
  // Try multiple thumbnail formats in order of preference
  // maxresdefault.jpg (1280x720) - highest quality
  // hqdefault.jpg (480x360) - high quality fallback
  // mqdefault.jpg (320x180) - medium quality fallback
  // default.jpg (120x90) - always available
  return "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
}

// Very lightweight meta content extractor (best-effort)
String? _matchMetaContent(String html, String property) {
  final regex = RegExp('<meta[^>]+property=["\']$property["\'][^>]*content=["\']([^"\']+)["\']', caseSensitive: false);
  final m = regex.firstMatch(html);
  return m?.group(1);
}

/// Create workout steps from exercise data
List<Map<String, dynamic>> _createWorkoutSteps(
  Map<String, dynamic> exerciseData,
) {
  return [
    {
      'stepNumber': 1,
      'title': 'Warm-up',
      'description': '5 minutes light warm-up and stretching',
      'duration': 300, // 5 minutes in seconds
      'image': null,
      'reps': null,
      'sets': null,
    },
    {
      'stepNumber': 2,
      'title': exerciseData['title'],
      'description': exerciseData['description'],
      'duration':
          (_estimateDuration(exerciseData['title']) - 10) *
          60, // convert to seconds
      'image': exerciseData['thumbnail'],
      'reps': 12,
      'sets': 3,
    },
    {
      'stepNumber': 3,
      'title': 'Cool Down',
      'description': '5 minutes stretching and relaxation',
      'duration': 300, // 5 minutes in seconds
      'image': null,
      'reps': null,
      'sets': null,
    },
  ];
}

class UploadExercisesScreen extends StatelessWidget {
  const UploadExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Exercises')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await uploadExercisesFromJson('assets/data/workouts.json');
          },
          child: const Text('Upload Exercises to Firestore'),
        ),
      ),
    );
  }
}

class UploadBrowserScreen extends StatefulWidget {
  final bool localOnly; // when true: import URL returns Exercise locally, no cloud write
  const UploadBrowserScreen({super.key, this.localOnly = false});

  @override
  State<UploadBrowserScreen> createState() => _UploadBrowserScreenState();
}

class _UploadBrowserScreenState extends State<UploadBrowserScreen> {
  bool _isUploading = false;
  String? _status;
  final TextEditingController _urlCtrl = TextEditingController();

  Future<void> _importFile(String assetPath) async {
    setState(() {
      _isUploading = true;
      _status = 'Uploading ' + assetPath + ' ...';
    });
    try {
      await uploadExercisesFromJson(assetPath);
      setState(() {
        _status = 'Uploaded successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ' + e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Workouts')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // URL input (Local only)
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                hintText: 'Paste workout URL (YouTube or article)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isUploading
                  ? null
                  : () async {
                      final url = _urlCtrl.text.trim();
                      if (url.isEmpty) return;
                      setState(() {
                        _isUploading = true;
                        _status = 'Importing from ' + url + ' ...';
                      });
                      try {
                        if (widget.localOnly) {
                          final ex = await parseExerciseFromUrl(url);
                          if (mounted) Navigator.pop(context, ex);
                          return;
                        } else {
                          await uploadWorkoutFromUrl(url);
                        }
                        setState(() => _status = 'Imported successfully!');
                      } catch (e) {
                        setState(() => _status = 'Error: ' + e.toString());
                      } finally {
                        if (mounted) setState(() => _isUploading = false);
                      }
                    },
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('Import URL (local only)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            // Cloud import removed from this screen to avoid duplicate entry points.
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(_status!),
            ],
          ],
        ),
      ),
    );
  }
}
