import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  String? _thumbnailPath;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  @override
  void didUpdateWidget(VideoThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    setState(() {
      _thumbnailPath = null;
      _isError = false;
    });

    try {
      // Sử dụng trực tiếp URL không cần tải video
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 150,
        quality: 75,
        timeMs: 1000, // Lấy frame ở giây thứ 1
      );

      if (thumbnailPath != null && File(thumbnailPath).existsSync()) {
        setState(() => _thumbnailPath = thumbnailPath);
      } else {
        setState(() => _isError = true);
      }
    } catch (e) {
      debugPrint('❌ Thumbnail error: $e');
      setState(() => _isError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return _buildErrorWidget();
    }

    return _thumbnailPath != null
        ? Image.file(
      File(_thumbnailPath!),
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      errorBuilder: (_, __, ___) => _buildErrorWidget(),
    )
        : Container(
      height: widget.height,
      width: widget.width,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}