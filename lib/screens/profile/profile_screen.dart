import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart'; // WAJIB: Pastikan import ini ada
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'about_screen.dart';
import 'help_screen.dart';
import 'plant_progress_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data user dari Provider
    // Catatan: Jika data user berubah di EditProfileScreen, Provider akan memicu rebuild di sini
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background abu muda lembut
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER: Title & Notifikasi ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pengaturan",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationsScreen()),
                      );
                    },
                    icon: const Icon(Icons.notifications_none, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- USER INFO SECTION (KODE INI DIPERBAIKI) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Tambahkan ini agar vertikal center
                children: [
                  // Gunakan Expanded agar Column mengambil sisa ruang yang tersedia
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama User dari Database
                        Text(
                          user?.name ?? "Nama Pengguna",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email User dari Database
                        Text(
                          user?.email ?? "email@example.com",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Icon Edit (Navigasi ke EditProfileScreen)
                  // Kita bungkus dengan SizedBox agar punya dimensi pasti
                  SizedBox(
                    width: 48, // Lebar yang cukup untuk tombol
                    height: 48, // Tinggi yang cukup untuk tombol
                    child: IconButton(
                      padding: EdgeInsets.zero, // Hapus padding default
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditProfileScreen()),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.black54),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // --- MENU LIST ---
              _buildMenuItem(
                icon: Icons.assignment_outlined,
                text: "Progress Tanaman",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlantProgressScreen()),
                  );
                },
              ),
              _buildDivider(),

              _buildMenuItem(
                icon: Icons.language,
                text: "Bahasa",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LanguageScreen()),
                  );
                },
              ),
              _buildDivider(),

              _buildMenuItem(
                icon: Icons.headset_mic_outlined,
                text: "Bantuan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                },
              ),
              _buildDivider(),

              _buildMenuItem(
                icon: Icons.notifications_none_outlined,
                text: "Notifikasi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              _buildDivider(),

              _buildMenuItem(
                icon: Icons.info_outline,
                text: "Tentang",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()),
                  );
                },
              ),
              _buildDivider(),

              // --- TAMBAHAN: TOMBOL LOGOUT ---
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Proses Logout
                    await authProvider.logout();
                    if (context.mounted) {
                      // Kembali ke Login Screen & Hapus semua stack halaman
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label:
                      const Text("Keluar", style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildMenuItem(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87, size: 26),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.black12,
      thickness: 1,
      height: 1,
    );
  }
}
