import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'history_page.dart';
import 'alerts_page.dart';
import 'settings_page.dart';
import '../services/real_auth_service.dart'; // ← Changer l'import

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final RealAuthService _auth = RealAuthService(); // ← Utiliser le service réel

  final List<Widget> _pages = [
    DashboardPage(),
    HistoryPage(),
    AlertsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.water_drop, color: Colors.white),
            SizedBox(width: 8),
            Text('PoolMaster'),
          ],
        ),
        backgroundColor: Color(0xFF0066CC),
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0066CC), Color(0xFF00B4D8)],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Tableau de bord',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historique',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning),
              label: 'Alertes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}