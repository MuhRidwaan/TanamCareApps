import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Contoh data notifikasi (dalam implementasi nyata, data ini bisa berasal dari provider/API)
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: "Pengingat Penyiraman",
      message: "Tanaman tomat Anda perlu disiram hari ini",
      time: "2 jam yang lalu",
      isRead: false,
      icon: Icons.water_drop,
      iconColor: Colors.blue,
    ),
    NotificationItem(
      title: "Pertumbuhan Tanaman",
      message: "Tanaman cabai Anda telah tumbuh 2 cm",
      time: "1 hari yang lalu",
      isRead: false,
      icon: Icons.eco,
      iconColor: Colors.green,
    ),
    NotificationItem(
      title: "Perawatan Rutin",
      message: "Jangan lupa memberikan pupuk untuk tanaman Anda",
      time: "2 hari yang lalu",
      isRead: true,
      icon: Icons.science,
      iconColor: Colors.orange,
    ),
    NotificationItem(
      title: "Tips Menanam",
      message: "Cara merawat tanaman di musim hujan",
      time: "3 hari yang lalu",
      isRead: true,
      icon: Icons.lightbulb,
      iconColor: Colors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in _notifications) {
                    notification.isRead = true;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Semua notifikasi ditandai sudah dibaca"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                "Tandai Semua",
                style: TextStyle(color: Color(0xFF2ECC71)),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            "Tidak ada notifikasi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Notifikasi baru akan muncul di sini",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade200
              : const Color(0xFF2ECC71).withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notification.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            notification.icon,
            color: notification.iconColor,
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification.time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF2ECC71),
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          setState(() {
            notification.isRead = true;
          });
        },
      ),
    );
  }
}

// Model untuk notifikasi
class NotificationItem {
  final String title;
  final String message;
  final String time;
  bool isRead;
  final IconData icon;
  final Color iconColor;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.iconColor,
  });
}

