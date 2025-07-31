import 'package:flutter/material.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khóa học'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header với lời chào và thông tin người dùng
          _buildHeader(),
          // Thanh điều hướng nhanh
          _buildCategoryFilter(),
          // Danh sách khóa học
          Expanded(
            child: _buildCourseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.deepPurple[100],
            child: const Icon(Icons.person, color: Colors.deepPurple),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chào buổi sáng, Nguyễn Văn A!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Hãy tiếp tục hành trình học tập của bạn",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.deepPurple[400]),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Tất cả', 'Phổ biến', 'Mới nhất', 'Đang học', 'Yêu thích'];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: index == 0,
              selectedColor: Colors.deepPurple,
              labelStyle: TextStyle(
                color: index == 0 ? Colors.white : Colors.black,
              ),
              onSelected: (selected) {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseList() {
    final courses = [
      {
        'title': 'Tiếng Anh cơ bản A1',
        'description': 'Dành cho người mới bắt đầu',
        'progress': 0.65,
        'lessons': 24,
        'time': '8 giờ',
        'image': Icons.language,
        'color': Colors.blue,
      },
      {
        'title': 'Giao tiếp hàng ngày',
        'description': 'Tự tin nói chuyện với người nước ngoài',
        'progress': 0.3,
        'lessons': 18,
        'time': '6 giờ',
        'image': Icons.chat,
        'color': Colors.green,
      },
      {
        'title': 'Luyện thi TOEIC 800+',
        'description': 'Chiến lược và mẹo thi TOEIC',
        'progress': 0.0,
        'lessons': 30,
        'time': '12 giờ',
        'image': Icons.assignment,
        'color': Colors.orange,
      },
      {
        'title': 'Ngữ pháp nâng cao',
        'description': 'Nắm vững cấu trúc ngữ pháp phức tạp',
        'progress': 0.85,
        'lessons': 20,
        'time': '10 giờ',
        'image': Icons.menu_book,
        'color': Colors.purple,
      },
      {
        'title': 'Phát âm chuẩn bản xứ',
        'description': 'Luyện phát âm và ngữ điệu tự nhiên',
        'progress': 0.45,
        'lessons': 15,
        'time': '5 giờ',
        'image': Icons.record_voice_over,
        'color': Colors.red,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: course['color'] as Color? ?? Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      course['image'] as IconData? ?? Icons.school,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['title'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course['description'] as String? ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.menu_book, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${course['lessons']} bài học',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${course['time']}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if ((course['progress'] as double) > 0)
                          LinearProgressIndicator(
                            value: course['progress'] as double? ?? 0,
                            backgroundColor: Colors.grey[300],
                            color: course['color'] as Color? ?? Colors.blue,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        if ((course['progress'] as double) > 0)
                          const SizedBox(height: 8),
                        if ((course['progress'] as double) > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tiến độ: ${((course['progress'] as double) * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                ),
                                child: const Text(
                                  'Tiếp tục học',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: course['color'] as Color? ?? Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Bắt đầu học'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}