import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/garden_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/translations.dart';
import '../auth/login_screen.dart';
import '../dashboard/my_garden_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gardenProvider = Provider.of<GardenProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLanguage;
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- GRADIENT HEADER ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2ECC71),
                      Color(0xFF27AE60),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2ECC71).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Avatar & Edit Button
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              (user?.name ?? 'U')[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2ECC71),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Color(0xFF2ECC71),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Name
                    Text(
                      user?.name ?? "Nama Pengguna",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 6),

                    // Email
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        SizedBox(width: 6),
                        Text(
                          user?.email ?? "email@example.com",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),

                    // if (user?.city != null) ...[
                    //   SizedBox(height: 6),
                    //   Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Icon(
                    //         Icons.location_on_outlined,
                    //         size: 16,
                    //         color: Colors.white.withOpacity(0.9),
                    //       ),
                    //       SizedBox(width: 6),
                    //       Text(
                    //         user!.city!,
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           color: Colors.white.withOpacity(0.9),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ],

                    SizedBox(height: 24),

                    // Stats Cards
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.local_florist,
                              value:
                                  gardenProvider.userPlants.length.toString(),
                              label:
                                  Translations.get(Translations.plants, lang),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.eco,
                              value: gardenProvider.userPlants
                                  .where((p) =>
                                      p.status.toLowerCase() == 'healthy')
                                  .length
                                  .toString(),
                              label:
                                  Translations.get(Translations.healthy, lang),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.calendar_today,
                              value: "0",
                              label: Translations.get(Translations.days, lang),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),
                  ],
                ),
              ),

              // --- MENU SECTIONS ---
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Garden Section
                    Text(
                      Translations.get(Translations.myGarden, lang),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(height: 12),

                    _buildMenuCard(
                      icon: Icons.grass,
                      iconColor: Color(0xFF2ECC71),
                      title: Translations.get(Translations.plantProgress, lang),
                      subtitle:
                          '${gardenProvider.userPlants.length} ${Translations.get(Translations.activePlants, lang)}',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyGardenScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24),

                    // Settings Section
                    Text(
                      Translations.get(Translations.settings, lang),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(height: 12),

                    _buildMenuCard(
                      icon: Icons.language,
                      iconColor: Colors.blue,
                      title: Translations.get(Translations.language, lang),
                      subtitle: lang == 'en' ? 'English' : 'Indonesia',
                      onTap: () {
                        _showLanguageDialog(context, languageProvider);
                      },
                    ),

                    SizedBox(height: 12),

                    _buildMenuCard(
                      icon: Icons.notifications_outlined,
                      iconColor: Colors.orange,
                      title: Translations.get(Translations.notifications, lang),
                      subtitle: Translations.get(
                          Translations.manageNotifications, lang),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24),

                    // Support Section
                    Text(
                      Translations.get(Translations.helpSupport, lang),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(height: 12),

                    _buildMenuCard(
                      icon: Icons.help_outline,
                      iconColor: Colors.purple,
                      title: Translations.get(Translations.helpCenter, lang),
                      subtitle: Translations.get(Translations.faqGuide, lang),
                      onTap: () {
                        _showHelpDialog(context, lang);
                      },
                    ),

                    SizedBox(height: 12),

                    _buildMenuCard(
                      icon: Icons.info_outline,
                      iconColor: Colors.teal,
                      title: Translations.get(Translations.aboutApp, lang),
                      subtitle:
                          '${Translations.get(Translations.version, lang)} 1.0.0',
                      onTap: () {
                        _showAboutDialog(context, lang);
                      },
                    ),

                    SizedBox(height: 32),

                    // Logout Button
                    InkWell(
                      onTap: () {
                        _showLogoutConfirmation(context, authProvider, lang);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.red,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.red, size: 22),
                            SizedBox(width: 10),
                            Text(
                              Translations.get(Translations.logout, lang),
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(
      BuildContext context, AuthProvider authProvider, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text(Translations.get(Translations.logoutConfirmTitle, lang)),
          ],
        ),
        content:
            Text(Translations.get(Translations.logoutConfirmMessage, lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translations.get(Translations.cancel, lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(Translations.get(Translations.logout, lang)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLanguage;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(Translations.get(Translations.selectLanguage, lang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text('🇮🇩', style: TextStyle(fontSize: 24)),
              title: Text('Indonesia'),
              trailing: lang == 'id'
                  ? Icon(Icons.check, color: Color(0xFF2ECC71))
                  : null,
              onTap: () async {
                await languageProvider.setLanguage('id');
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: Text('English'),
              trailing: lang == 'en'
                  ? Icon(Icons.check, color: Color(0xFF2ECC71))
                  : null,
              onTap: () async {
                await languageProvider.setLanguage('en');
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.purple),
            SizedBox(width: 10),
            Text(Translations.get(Translations.helpCenter, lang)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Translations.get(Translations.frequentQuestions, lang),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              _buildFAQItem(
                Translations.get(Translations.faqHowToAdd, lang),
                Translations.get(Translations.faqHowToAddAnswer, lang),
              ),
              _buildFAQItem(
                Translations.get(Translations.faqHowToScan, lang),
                Translations.get(Translations.faqHowToScanAnswer, lang),
              ),
              _buildFAQItem(
                Translations.get(Translations.faqHowToLog, lang),
                Translations.get(Translations.faqHowToLogAnswer, lang),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translations.get(Translations.close, lang)),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: Color(0xFF2ECC71),
            ),
            SizedBox(height: 12),
            Text('TanamCare'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${Translations.get(Translations.version, lang)} 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Text(
              Translations.get(Translations.aboutDescription, lang),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Text(
              Translations.get(Translations.copyright, lang),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translations.get(Translations.close, lang)),
          ),
        ],
      ),
    );
  }
}
