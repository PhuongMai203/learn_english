import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../../../../../components/app_background.dart';
import '../../../widgets/VideoThumbnailWidget.dart';

class EditLessonScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;
  final Map<String, dynamic> lessonData;

  const EditLessonScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.lessonData,
  });

  @override
  State<EditLessonScreen> createState() => _EditLessonScreenState();
}

class _EditLessonScreenState extends State<EditLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _youtubeLinkController;

  File? _selectedMedia;
  String? _mediaUrl;
  bool _isUploading = false;

  final picker = ImagePicker();
  VideoPlayerController? _videoController;

  bool get isYoutubeLink =>
      _mediaUrl?.contains("youtube.com") == true ||
          _mediaUrl?.contains("youtu.be") == true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lessonData['title']);
    _descriptionController =
        TextEditingController(text: widget.lessonData['description']);
    _youtubeLinkController = TextEditingController(
      text: widget.lessonData['mediaUrl']?.toString().contains("youtube.com") == true
          ? widget.lessonData['mediaUrl']
          : '',
    );
    _mediaUrl = widget.lessonData['mediaUrl'];

    if (_mediaUrl != null && _mediaUrl!.isNotEmpty && !isYoutubeLink) {
      _checkAndInitializeMedia();
    }
  }

  void _checkAndInitializeMedia() {
    final fileType = _getFileType(_mediaUrl!);
    if (fileType == 'mp4') {
      _initializeVideo(_mediaUrl!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeLinkController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo(String url) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  Future<void> _initializeVideoFromFile(File file) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final pickedFile = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _selectedMedia = file;
      });

      if (isVideo) {
        await _initializeVideoFromFile(file);
      } else {
        _videoController?.dispose();
        setState(() {
          _videoController = null;
        });
      }
    }
  }

  Future<String?> _uploadToFirebase(File file) async {
    try {
      final originalFileName = path.basename(file.path);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$originalFileName';
      final ref =
      FirebaseStorage.instance.ref().child('lessons').child(fileName);

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      debugPrint('✅ Firebase download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }

  Future<void> _updateLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? finalMediaUrl = _youtubeLinkController.text.trim();

      if (_selectedMedia != null) {
        final uploadedUrl = await _uploadToFirebase(_selectedMedia!);
        if (uploadedUrl != null) {
          finalMediaUrl = uploadedUrl;
        }
      }

      final lessonRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('lessons')
          .doc(widget.lessonId);

      await lessonRef.update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'mediaUrl': finalMediaUrl,
        'updatedAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bài học đã được cập nhật!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Lỗi khi cập nhật bài học: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  String? _getFileType(String url) {
    try {
      final uri = Uri.parse(url);
      String path = uri.path;
      int lastDotIndex = path.lastIndexOf('.');
      if (lastDotIndex != -1 && lastDotIndex < path.length - 1) {
        return path.substring(lastDotIndex + 1).toLowerCase();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 50,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
              ),
            ],
          ),
        ),
        VideoProgressIndicator(
          _videoController!,
          allowScrubbing: true,
          colors: const VideoProgressColors(
            playedColor: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview(String url) {
    final fileType = _getFileType(url);

    if (fileType == null) {
      return const Text("📁 File không hỗ trợ xem trước");
    }

    switch (fileType) {
      case 'mp4':
      case 'mov':
      case 'avi':
        return _buildVideoPlayer();
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Image.network(
          url,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Text('Không tải được ảnh'),
        );
      default:
        return const Text("📁 File không hỗ trợ xem trước");
    }
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("YouTube hoặc tải media từ thiết bị:"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _youtubeLinkController,
          decoration: InputDecoration(
            labelText: 'Link YouTube (nếu có)',
            prefixIcon: const Icon(Icons.link, color: Colors.teal),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.teal.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.image, color: Colors.white,),
              onPressed: () => _pickMedia(ImageSource.gallery, isVideo: false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[400]),
              label: Text("Tải ảnh từ máy",
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.video_file, color: Colors.white,),
              onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[400]),
              label: Text("Tải video từ máy",
                style: TextStyle(
                    color: Colors.white
                ),),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_selectedMedia != null)
          _selectedMedia!.path.endsWith('.mp4')
              ? _buildVideoPlayer()
              : Image.file(
            _selectedMedia!,
            height: 180,
            fit: BoxFit.cover,
          ),

        const SizedBox(height: 12),

        if (_selectedMedia == null && _mediaUrl != null && _mediaUrl!.isNotEmpty)
          isYoutubeLink
              ? Text("Đang dùng link YouTube: $_mediaUrl")
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Media hiện tại:"),
              const SizedBox(height: 8),
              _buildMediaPreview(_mediaUrl!),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Chỉnh sửa bài học', style: TextStyle(color: Colors.teal[700])),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề',
                    prefixIcon: const Icon(Icons.title, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.teal.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Nhập tiêu đề' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    prefixIcon: const Icon(Icons.description, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.teal.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Nhập mô tả' : null,
                ),
                const SizedBox(height: 16),
                _buildMediaSection(),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _updateLesson,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isUploading ? 'Đang lưu...' : 'Cập nhật bài học',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
