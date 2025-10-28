// pages/admin_dashboard.dart
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildStatCard('Piscines Actives', '12', Icons.pool),
          _buildStatCard('Alertes Actives', '3', Icons.warning),
          _buildStatCard('Utilisateurs', '45', Icons.people),
          _buildStatCard('Économie d\'énergie', '15%', Icons.eco),
        ],
      ),
    );
  }
}