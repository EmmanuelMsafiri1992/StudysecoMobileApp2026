import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/lessons_provider.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String lessonId;

  const LessonPlayerScreen({super.key, required this.lessonId});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    final provider = context.read<LessonsProvider>();
    await provider.fetchLessonDetail(widget.lessonId);

    if (provider.currentLesson?.videoUrl != null) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(provider.currentLesson!.videoUrl!),
      );
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<LessonsProvider>(
        builder: (context, provider, _) {
          final lesson = provider.currentLesson;

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (lesson == null) {
            return const Center(
              child: Text('Lesson not found', style: TextStyle(color: Colors.white)),
            );
          }

          return Column(
            children: [
              // Video player
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(Icons.play_circle, size: 64, color: Colors.white54),
                        ),
                      ),
              ),

              // Lesson info
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(lesson.durationFormatted, style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                        if (lesson.description != null) ...[
                          const SizedBox(height: 16),
                          Text(lesson.description!, style: TextStyle(color: Colors.grey.shade700)),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final prev = provider.getPreviousLesson();
                                  if (prev != null) {
                                    context.pushReplacement('/lesson/${prev.id}/play');
                                  }
                                },
                                icon: const Icon(Icons.skip_previous),
                                label: const Text('Previous'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await provider.markLessonComplete(lesson.id);
                                  final next = provider.getNextLesson();
                                  if (next != null && context.mounted) {
                                    context.pushReplacement('/lesson/${next.id}/play');
                                  }
                                },
                                icon: const Icon(Icons.skip_next),
                                label: const Text('Next'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
