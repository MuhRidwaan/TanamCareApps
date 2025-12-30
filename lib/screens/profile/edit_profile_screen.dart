import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  // PERBAIKAN: Typo TextEdauth_serviceitingController -> TextEditingController
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Isi otomatis form dengan data user saat ini
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
          "Edit Profil",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FORM NAMA ---
              _buildLabel("Nama Lengkap"),
              TextFormField(
                controller: _nameController,
                validator: (val) =>
                    val!.isEmpty ? "Nama tidak boleh kosong" : null,
                decoration: _inputDecoration("Masukkan nama lengkap"),
              ),
              const SizedBox(height: 20),

              // --- FORM NAMA DEPAN ---
              _buildLabel("Nama Depan"),
              TextFormField(
                controller: _firstNameController,
                validator: (val) =>
                    val!.isEmpty ? "Nama depan tidak boleh kosong" : null,
                decoration: _inputDecoration("Masukkan nama depan"),
              ),
              const SizedBox(height: 20),

              // --- FORM NAMA BELAKANG ---
              _buildLabel("Nama Belakang"),
              TextFormField(
                controller: _lastNameController,
                validator: (val) =>
                    val!.isEmpty ? "Nama belakang tidak boleh kosong" : null,
                decoration: _inputDecoration("Masukkan nama belakang"),
              ),
              const SizedBox(height: 20),

              // --- FORM EMAIL ---
              _buildLabel("Email"),
              TextFormField(
                controller: _emailController,
                validator: (val) =>
                    val!.isEmpty ? "Email tidak boleh kosong" : null,
                decoration: _inputDecoration("Masukkan email aktif"),
              ),
              const SizedBox(height: 20),

              // --- FORM PASSWORD (OPSIONAL) ---
              _buildLabel("Password Baru (Opsional)"),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                // Tidak ada validator wajib, karena boleh kosong
                decoration: _inputDecoration("Isi jika ingin ubah password"),
              ),
              const SizedBox(height: 10),
              const Text(
                "* Kosongkan jika tidak ingin mengubah password",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 40),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authProvider.updateProfile(
                              _nameController.text,
                              _emailController.text,
                              _passwordController.text.isEmpty
                                  ? null // Kirim null jika kosong
                                  : _passwordController.text,
                            );

                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Profil Berhasil Diupdate!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(
                                  context); // Kembali ke halaman Profile
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authProvider.errorMessage ??
                                      "Gagal update"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SIMPAN PERUBAHAN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2),
      ),
    );
  }
}
