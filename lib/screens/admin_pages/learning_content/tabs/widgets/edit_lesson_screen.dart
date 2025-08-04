import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart'; // ✅ Thêm dòng này

import '../../../../../components/app_background.dart';

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

  VideoPlayerController? _videoController; // ✅

  bool get isYoutubeLink =>
      _mediaUrl?.contains("youtube.com") == true || _mediaUrl?.contains("youtu.be") == true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lessonData['title']);
    _descriptionController = TextEditingController(text: widget.lessonData['description']);
    _youtubeLinkController = TextEditingController(
      text: widget.lessonData['mediaUrl']?.toString().contains("youtube.com") == true
          ? widget.lessonData['mediaUrl']
          : '',
    );
    _mediaUrl = widget.lessonData['mediaUrl'];

    if (_mediaUrl != null && _mediaUrl!.endsWith(".mp4")) {
      _initializeVideo(_mediaUrl!); // ✅
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeLinkController.dispose();
    _videoController?.dispose(); // ✅
    super.dispose();
  }

  Future<void> _initializeVideo(String url) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();
    setState(() {});
  }

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final pickedFile = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadToFirebase(File file) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final ref = FirebaseStorage.instance.ref().child('lessons').child(fileName);

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
          const SnackBar(content: Text('✅ Bài học đã được cập nhật!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi cập nhật bài học: $e');
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

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("YouTube hoặc tải media từ thiết bị:"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _youtubeLinkController,
          decoration: const InputDecoration(
            labelText: 'Link YouTube (nếu có)',
            prefixIcon: Icon(Icons.link),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              onPressed: () => _pickMedia(ImageSource.gallery, isVideo: false),
              label: const Text("Tải ảnh từ máy"),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.video_file),
              onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
              label: const Text("Tải video từ máy"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedMedia != null)
          Text(
            "Đã chọn: ${path.basename(_selectedMedia!.path)}",
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 12),
        if (_mediaUrl != null && _mediaUrl!.isNotEmpty)
          isYoutubeLink
              ? Text("Đang dùng link YouTube: $_mediaUrl")
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Media hiện tại:"),
              const SizedBox(height: 8),
              if (_mediaUrl!.endsWith(".mp4"))
                _videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_videoController!),
                      VideoProgressIndicator(_videoController!, allowScrubbing: true),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(
                            _videoController!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _videoController!.value.isPlaying
                                  ? _videoController!.pause()
                                  : _videoController!.play();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                )
                    : const Text("🔄 Đang tải video...")
              else
                Image.network(
                  _mediaUrl!,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Text('❌ Không tải được ảnh'),
                ),
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
          title: Text('Chỉnh sửa bài học', style: TextStyle(color: Colors.orange.shade200)),
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
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Nhập tiêu đề' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'Nhập mô tả' : null,
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
                    backgroundColor: const Color(0xD8FFB833),
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
