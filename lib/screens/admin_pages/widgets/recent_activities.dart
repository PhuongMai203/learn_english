import 'package:flutter/material.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoạt động gần đây',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: const [
              ActivityItem(
                user: 'Nguyễn Văn A',
                action: 'đã hoàn thành khóa học Ngữ pháp nâng cao',
                time: '10 phút trước',
              ),
              ActivityItem(
                user: 'Trần Thị B',
                action: 'đã đăng ký khóa học mới',
                time: '25 phút trước',
              ),
              ActivityItem(
                user: 'Lê Văn C',
                action: 'đã gửi bài tập viết luận',
                time: '1 giờ trước',
              ),
              ActivityItem(
                user: 'Phạm Thị D',
                action: 'được thăng hạng Vàng',
                time: '2 giờ trước',
              ),
              ActivityItem(
                user: 'Hoàng Văn E',
                action: 'đã bình luận trong diễn đàn',
                time: '3 giờ trước',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActivityItem extends StatelessWidget {
  final String user;
  final String action;
  final String time;

  const ActivityItem({
    super.key,
    required this.user,
    required this.action,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage: AssetImage('assets/user_avatar.png'),
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: user,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: ' $action',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        time,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.grey),
    );
  }
}
