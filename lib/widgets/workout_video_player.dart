import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../common/color_extension.dart';

/// --- Utils: extract Youtube videoId from many URL shapes (watch, embed, youtu.be, shorts)
String extractYoutubeId(String url) {
  if (url.isEmpty) return '';
  url = url.trim();

  // /embed/<id>
  final embed = RegExp(
    r'youtube\.com/embed/([A-Za-z0-9_-]{11})',
  ).firstMatch(url);
  if (embed != null) return embed.group(1)!;

  // watch?v=<id>
  final watch = RegExp(r'[?&]v=([A-Za-z0-9_-]{11})').firstMatch(url);
  if (watch != null) return watch.group(1)!;

  // youtu.be/<id>
  final short = RegExp(r'youtu\.be/([A-Za-z0-9_-]{11})').firstMatch(url);
  if (short != null) return short.group(1)!;

  // shorts/<id>
  final shorts = RegExp(
    r'youtube\.com/shorts/([A-Za-z0-9_-]{11})',
  ).firstMatch(url);
  if (shorts != null) return shorts.group(1)!;

  // raw id
  final raw = RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(url);
  if (raw) return url;

  return '';
}

/// --- Fallback widget: when inline player can't be used, open externally
class _FallbackOpenExternal extends StatelessWidget {
  final String title;
  final String thumbnailUrl;
  final String rawUrl;

  const _FallbackOpenExternal({
    required this.title,
    required this.thumbnailUrl,
    required this.rawUrl,
  });

  Future<void> _openExternal() async {
    final id = extractYoutubeId(rawUrl);
    try {
      if (id.isNotEmpty) {
        final app = Uri.parse('youtube://watch?v=$id');
        if (await canLaunchUrl(app)) {
          await launchUrl(app, mode: LaunchMode.externalApplication);
          return;
        }
        final web = Uri.parse('https://www.youtube.com/watch?v=$id');
        await launchUrl(web, mode: LaunchMode.externalApplication);
      } else {
        final uri = Uri.parse(rawUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // swallow; UI remains
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openExternal,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnailUrl.startsWith('http'))
              Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey.shade300),
              )
            else
              Container(color: Colors.grey.shade300),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> workout;
  final bool autoPlay;

  const WorkoutVideoPlayer({
    super.key,
    required this.workout,
    this.autoPlay = false,
  });

  @override
  State<WorkoutVideoPlayer> createState() => _WorkoutVideoPlayerState();
}

class _WorkoutVideoPlayerState extends State<WorkoutVideoPlayer> {
  late final YoutubePlayerController _yt;
  String _videoUrl = '';
  String _videoId = '';
  String _thumbnailUrl = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      _videoUrl = (widget.workout['videoUrl'] ?? '').toString();
      _videoId = extractYoutubeId(_videoUrl);
      _thumbnailUrl =
          widget.workout['thumbnail'] ??
          widget.workout['videoMetadata']?['thumbnailUrl'] ??
          (_videoId.isNotEmpty
              ? 'https://img.youtube.com/vi/$_videoId/hqdefault.jpg'
              : '');

      _yt = YoutubePlayerController.fromVideoId(
        videoId: _videoId,
        autoPlay: widget.autoPlay, // autoplay có thể bị chặn nếu có tiếng
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          strictRelatedVideos: true,
          playsInline: true, // iOS cần
        ),
      );
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      // Tạo controller rỗng để tránh null
      _yt = YoutubePlayerController.fromVideoId(videoId: '');
    }
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Card layout giữ nguyên như bạn, chỉ thay phần video thành player inline/fallback
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video area
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _videoId.isNotEmpty
                  ? YoutubePlayer(controller: _yt)
                  : _FallbackOpenExternal(
                      title: widget.workout['title'] ?? 'Workout Video',
                      thumbnailUrl: _thumbnailUrl,
                      rawUrl: _videoUrl,
                    ),
            ),

            // --- Video Info (giữ nguyên layout của bạn)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workout['title'] ?? 'Workout',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.fitness_center, size: 16, color: TColor.gray),
                      const SizedBox(width: 4),
                      Text(
                        widget.workout['muscleGroup'] ?? 'Full Body',
                        style: TextStyle(color: TColor.gray, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: TColor.gray),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.workout['duration'] ?? 20} min',
                        style: TextStyle(color: TColor.gray, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.workout['calories'] ?? 100} cal',
                        style: TextStyle(color: TColor.gray, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.workout['description'] ?? 'No description available',
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Nút Play giữ lại nhưng đổi hành vi: scroll vào player & bấm play qua API nếu muốn
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_videoId.isEmpty) return;
                        // Gọi play qua API; nếu bị chặn do policy, user vẫn có thể bấm Play thủ công
                        _yt.playVideo();
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        'Watch Video',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primaryColor1,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact video player for workout detail steps (inline + fallback)
class CompactVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const CompactVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<CompactVideoPlayer> createState() => _CompactVideoPlayerState();
}

class _CompactVideoPlayerState extends State<CompactVideoPlayer> {
  late final YoutubePlayerController _yt;
  String _videoId = '';
  String _thumbnailUrl = '';

  @override
  void initState() {
    super.initState();
    try {
      _videoId = extractYoutubeId(widget.videoUrl);
      _thumbnailUrl = _videoId.isNotEmpty
          ? 'https://img.youtube.com/vi/$_videoId/hqdefault.jpg'
          : '';
      _yt = YoutubePlayerController.fromVideoId(
        videoId: _videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          playsInline: true,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing compact video player: $e');
      _yt = YoutubePlayerController.fromVideoId(videoId: '');
    }
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library, size: 48, color: TColor.gray),
              const SizedBox(height: 8),
              Text('Video not available', style: TextStyle(color: TColor.gray)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: YoutubePlayer(controller: _yt),
      ),
    );
  }
}
