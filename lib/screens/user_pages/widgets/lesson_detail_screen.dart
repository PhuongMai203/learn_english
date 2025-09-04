import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String mediaUrl;
  final bool isVideo;

  const LessonDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.isVideo,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;

  bool get isYoutubeUrl =>
      widget.mediaUrl.contains("youtube.com") ||
          widget.mediaUrl.contains("youtu.be");

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      if (isYoutubeUrl) {
        final videoId = YoutubePlayer.convertUrlToId(widget.mediaUrl);
        if (videoId != null && videoId.isNotEmpty) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
        }
      } else {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.mediaUrl),
        )..initialize().then((_) {
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: false,
            looping: false,
            aspectRatio: _videoController!.value.aspectRatio,
          );
          setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFFFF7B54),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isVideo && _youtubeController != null)
              YoutubePlayer(controller: _youtubeController!)
            else if (widget.isVideo &&
                _videoController != null &&
                _videoController!.value.isInitialized &&
                _chewieController != null)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            else if (widget.isVideo)
                const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 16),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
