import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Notifikasi")),
      body: const Center(
        child: Text("Fitur Notifikasi Belum Tersedia"),
      ),
    );
  }
}
