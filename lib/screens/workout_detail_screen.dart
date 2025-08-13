import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../common/color_extension.dart';
import '../models/workout.dart';
import '../services/exercise_service.dart';
import '../widgets/round_button.dart';
import '../widgets/top_notification_banner.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  bool _isFavorite = false;
  bool _isLoading = true;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black);

    // Debug removed for performance

    // Only load video if URL is valid
    if (widget.workout.videoUrl != null &&
        widget.workout.videoUrl!.isNotEmpty &&
        (widget.workout.videoUrl!.startsWith('http://') ||
            widget.workout.videoUrl!.startsWith('https://'))) {
      // Loading video
      _webViewController.loadRequest(Uri.parse(widget.workout.videoUrl!));
    } else {
      // No valid video URL
    }
  }

  void _showVideoDialog() {
    if (widget.workout.videoUrl == null ||
        widget.workout.videoUrl!.isEmpty ||
        (!widget.workout.videoUrl!.startsWith('http://') &&
            !widget.workout.videoUrl!.startsWith('https://'))) {
      showTopBanner(
        context,
        title: 'No Video',
        message: 'No video available for this workout',
        backgroundColor: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: Stack(
            children: [
              // Video Player
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: WebViewWidget(controller: _webViewController),
              ),
              // Close Button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/img/Workout1.png');
    }

    // Check if it's a valid URL with scheme
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }

    // If it's a local asset path
    if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    }

    // Default fallback
    return const AssetImage('assets/img/Workout1.png');
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      // Check if workout is in favorites by checking the isFavorite field
      setState(() {
        _isFavorite = widget.workout.isFavorite;
        _isLoading = false;
      });
    } catch (e) {
      // swallow
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      await _exerciseService.toggleFavorite(widget.workout.id);
      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (mounted) {
        showTopBanner(
          context,
          title: _isFavorite ? 'Favorites' : 'Favorites',
          message:
              _isFavorite ? 'Added to favorites!' : 'Removed from favorites!',
          backgroundColor: _isFavorite ? Colors.green : Colors.orange,
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
        );
      }
    } catch (e) {
      // swallow
      if (mounted) {
        showTopBanner(
          context,
          title: 'Error',
          message: 'Error updating favorites: $e',
          backgroundColor: Colors.red,
          icon: Icons.error_outline,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _getImageProvider(widget.workout.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Watch Video Button (if video exists)
                  if (widget.workout.videoUrl != null &&
                      widget.workout.videoUrl!.isNotEmpty)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
                          ),
                          onPressed: _showVideoDialog,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _isLoading ? null : _toggleFavorite,
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.workout.name,
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: TColor.secondaryG),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.workout.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.local_fire_department,
                        value: '${widget.workout.calories}',
                        label: 'Calories',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.timer,
                        value: '${widget.workout.duration}',
                        label: 'Minutes',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.fitness_center,
                        value: widget.workout.difficulty ?? 'Intermediate',
                        label: 'Level',
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Equipment (hide if empty or only bodyweight)
                  if ((widget.workout.equipment?.trim().isNotEmpty ?? false) &&
                      (widget.workout.equipment!.trim().toLowerCase() != 'bodyweight') &&
                      (widget.workout.equipment!.trim().toLowerCase() != 'none')) ...[
                    Text(
                      'Equipment Needed',
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TColor.gray.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sports_gymnastics,
                            color: TColor.primaryColor1,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.workout.equipment!,
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.workout.description,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Watch Video Button (if video exists)
                  if (widget.workout.videoUrl != null &&
                      widget.workout.videoUrl!.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: RoundButton(
                        title: "Watch Video",
                        type: RoundButtonType.bgGradient,
                        onPressed: _showVideoDialog,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Start Workout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: RoundButton(
                      title: "Start Workout",
                      type: RoundButtonType.bgGradient,
                      onPressed: () async {
                        try {
                          // Complete the workout
                          await _exerciseService.completeWorkout(
                            widget.workout.id,
                          );

                          if (mounted) {
                            showTopBanner(
                              context,
                              title: 'Workout',
                              message: 'Workout completed! Added to history.',
                              backgroundColor: Colors.green,
                              icon: Icons.check_circle_outline,
                            );

                            // Return true to refresh the workout list
                            Navigator.pop(context, true);
                          }
                        } catch (e) {
                          if (mounted) {
                            showTopBanner(
                              context,
                              title: 'Error',
                              message: 'Error completing workout: $e',
                              backgroundColor: Colors.red,
                              icon: Icons.error_outline,
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: TextStyle(color: TColor.gray, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
