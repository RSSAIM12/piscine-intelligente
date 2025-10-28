import 'package:flutter/material.dart';
import 'login_page.dart';
import '../services/real_auth_service.dart'; // ← Changer l'import

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final RealAuthService _auth = RealAuthService(); // ← Utiliser le service réel
  bool _notifications = true;
  bool _autoPump = false;
  double _phMin = 6.5;
  double _phMax = 8.0;
  double _tempMin = 20.0;
  double _tempMax = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Paramètres de la piscine'),
            _buildSettingCard(
              'Seuils de qualité d\'eau',
              Icons.water_drop,
              Column(
                children: [
                  _buildRangeSlider('pH', _phMin, _phMax, 6.0, 9.0, (values) {
                    setState(() {
                      _phMin = values.start;
                      _phMax = values.end;
                    });
                  }),
                  SizedBox(height: 16),
                  _buildRangeSlider('Température (°C)', _tempMin, _tempMax, 15.0, 35.0, (values) {
                    setState(() {
                      _tempMin = values.start;
                      _tempMax = values.end;
                    });
                  }),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildSectionHeader('Préférences'),
            _buildSettingCard(
              'Notifications',
              Icons.notifications,
              SwitchListTile(
                title: Text('Activer les notifications'),
                value: _notifications,
                onChanged: (value) => setState(() => _notifications = value),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              'Contrôle automatique',
              Icons.auto_mode,
              SwitchListTile(
                title: Text('Pompe automatique'),
                subtitle: Text('Ajuster automatiquement la pompe'),
                value: _autoPump,
                onChanged: (value) => setState(() => _autoPump = value),
              ),
            ),
            SizedBox(height: 16),
            _buildSectionHeader('Compte'),
            _buildSettingCard(
              'Sécurité',
              Icons.security,
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Changer l\'email'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Changer le mot de passe'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              'Déconnexion',
              Icons.logout,
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: _signOut,
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0066CC),
        ),
      ),
    );
  }

  Widget _buildSettingCard(String title, IconData icon, Widget content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF0066CC)),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSlider(String label, double min, double max, double absoluteMin, double absoluteMax, Function(RangeValues) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${min.toStringAsFixed(1)} - ${max.toStringAsFixed(1)}',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(min, max),
          min: absoluteMin,
          max: absoluteMax,
          divisions: 20,
          labels: RangeLabels(
            min.toStringAsFixed(1),
            max.toStringAsFixed(1),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }
}