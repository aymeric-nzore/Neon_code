import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'soil/soil_analysis_screen.dart';
import 'disease/disease_detection_screen.dart';
import 'chat/chatbot_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  static MainNavigationScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainNavigationScreenState>();

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SoilAnalysisScreen(),
    ChatbotScreen(), // Center Button
    DiseaseDetectionScreen(),
    SettingsScreen(), // Profile Tab
  ];

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 96,
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Floating Bar Container
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withOpacity(0.03)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Item 0: Home (Accueil)
                    _buildNavItem(0, Icons.home_outlined, Icons.home, "Accueil", AppTheme.primaryGreen),
                    // Item 1: Soil (Sol)
                    _buildNavItem(1, Icons.analytics_outlined, Icons.analytics, "Sol", AppTheme.primaryOrange),
                    
                    // Empty spacer to leave room for the elevated center button
                    const SizedBox(width: 56),
                    
                    // Item 3: Disease Detection (Santé)
                    _buildNavItem(3, Icons.camera_alt_outlined, Icons.camera_alt, "Santé", AppTheme.primaryGreen),
                    // Item 4: Profile (Settings)
                    _buildNavItem(4, Icons.person_outline, Icons.person, "Profil", AppTheme.primaryOrange),
                  ],
                ),
              ),
            ),

            // Elevated Center Button (AgriIA Chatbot)
            Positioned(
              bottom: 30, // Elevated overlap
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold, // Warm golden orange
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: _currentIndex == 2 ? 4.0 : 3.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded, // Robot/AI head
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
    Color activeColor,
  ) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? activeColor : AppTheme.textMuted,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
