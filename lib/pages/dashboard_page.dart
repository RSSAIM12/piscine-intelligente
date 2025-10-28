import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/real_auth_service.dart';
import '../services/real_firestore_service.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final RealAuthService _authService = RealAuthService();
  final RealFirestoreService _firestoreService = RealFirestoreService();
  late String poolId;
  
  @override
  void initState() {
    super.initState();
    poolId = _authService.getCurrentUserPoolId();
    _firestoreService.startDataSimulation(poolId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestoreService.getPoolData(poolId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Configuration de votre piscine...'));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatusCard(data),
              SizedBox(height: 16),
              _buildMetricsGrid(data),
              SizedBox(height: 16),
              _buildProgressIndicators(data),
              SizedBox(height: 16),
              _buildMLPredictions(),
              SizedBox(height: 16),
              _buildCloudServicesInfo(),
              SizedBox(height: 16),
              _buildQuickControls(data),
              SizedBox(height: 16),
              _buildFirebaseInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFirebaseInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_done, color: Colors.green, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Firebase Cloud Actif',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Données synchronisées en temps réel avec Firestore',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMLPredictions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intelligence Artificielle - Prédictions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0066CC),
              ),
            ),
            SizedBox(height: 16),
            _buildPredictionItem('Qualité eau', 'EXCELLENTE', Colors.green),
            _buildPredictionItem('Risque algues', 'FAIBLE', Colors.green),
            _buildPredictionItem('Consommation énergétique', 'OPTIMALE', Colors.blue),
            _buildPredictionItem('Maintenance préventive', 'DANS 7 JOURS', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(String title, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudServicesInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services Cloud Utilisés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0066CC),
              ),
            ),
            SizedBox(height: 16),
            _buildCloudServiceItem('Firebase Firestore', 'Base de données temps réel', Icons.cloud),
            _buildCloudServiceItem('Firebase Auth', 'Authentification sécurisée', Icons.security),
            _buildCloudServiceItem('Cloud Functions', 'Logique métier serverless', Icons.functions),
            _buildCloudServiceItem('AI Platform', 'Machine Learning', Icons.psychology),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudServiceItem(String title, String description, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF0066CC)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
    );
  }

  Widget _buildProgressIndicators(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Niveaux en temps réel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildProgressBar('Niveau d\'eau', data['water_level']?.toDouble() ?? 0.0, Colors.blue),
            SizedBox(height: 12),
            _buildProgressBar('Niveau pH', ((data['ph']?.toDouble() ?? 7.0) - 6.0) * 50, Colors.green),
            SizedBox(height: 12),
            _buildProgressBar('Température', (data['temperature']?.toDouble() ?? 25.0) - 15, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    double percentage = value.clamp(0.0, 100.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
            Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(color: color)),
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[200],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Température',
          '${data['temperature']?.toStringAsFixed(1) ?? '--'}°C',
          Icons.thermostat,
          _getTemperatureColor(data['temperature']?.toDouble()),
        ),
        _buildMetricCard(
          'Niveau pH',
          data['ph']?.toStringAsFixed(1) ?? '--',
          Icons.science,
          _getPHColor(data['ph']?.toDouble()),
        ),
        _buildMetricCard(
          'Niveau d\'eau',
          '${data['water_level']?.toStringAsFixed(0) ?? '--'}%',
          Icons.waves,
          _getWaterLevelColor(data['water_level']?.toDouble()),
        ),
        _buildMetricCard(
          'Pompe',
          data['pump_status'] == true ? 'ACTIVE' : 'ARRÊT',
          Icons.power_settings_new,
          data['pump_status'] == true ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Color _getTemperatureColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp < 20) return Colors.blue;
    if (temp > 30) return Colors.red;
    return Colors.green;
  }

  Color _getPHColor(double? ph) {
    if (ph == null) return Colors.grey;
    if (ph < 6.5 || ph > 8.0) return Colors.red;
    if (ph < 6.8 || ph > 7.8) return Colors.orange;
    return Colors.green;
  }

  Color _getWaterLevelColor(double? level) {
    if (level == null) return Colors.grey;
    if (level < 50) return Colors.red;
    if (level < 70) return Colors.orange;
    return Colors.green;
  }

  Widget _buildStatusCard(Map<String, dynamic> data) {
    Color statusColor = Colors.green;
    String status = 'Excellent';
    String description = 'Tous les paramètres sont optimaux';

    double? ph = data['ph'];
    double? waterLevel = data['water_level'];
    double? temperature = data['temperature'];

    if (ph != null && (ph < 6.5 || ph > 8.0)) {
      statusColor = Colors.red;
      status = 'Attention pH';
      description = 'Le pH est en dehors des limites recommandées';
    } else if (waterLevel != null && waterLevel < 50) {
      statusColor = Colors.red;
      status = 'Niveau bas';
      description = 'Le niveau d\'eau est trop bas';
    } else if (temperature != null && (temperature < 18 || temperature > 32)) {
      statusColor = Colors.orange;
      status = 'Température extrême';
      description = 'La température n\'est pas optimale';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(statusColor),
                color: statusColor,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut piscine',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(Color statusColor) {
    if (statusColor == Colors.green) return Icons.check_circle;
    if (statusColor == Colors.orange) return Icons.info;
    return Icons.warning;
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickControls(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contrôles rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildControlButton(
                  'Pompe',
                  Icons.power_settings_new,
                  data['pump_status'] == true ? Colors.green : Colors.grey,
                  () => _togglePump(!(data['pump_status'] == true)),
                ),
                _buildControlButton(
                  'Rafraîchir',
                  Icons.refresh,
                  Colors.blue,
                  _refreshData,
                ),
                _buildControlButton(
                  'Alertes',
                  Icons.warning,
                  Colors.orange,
                  () => _showAlerts(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String label, IconData icon, Color color, Function onTap) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: () => onTap(),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _togglePump(bool newStatus) {
    _firestoreService.updatePumpStatus(poolId, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pompe ${newStatus ? 'activée' : 'arrêtée'}'),
        backgroundColor: newStatus ? Colors.green : Colors.red,
      ),
    );
  }

  void _refreshData() {
    _firestoreService.addSimulatedSensorData(poolId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Données rafraîchies')),
    );
  }

  void _showAlerts() {
    // Navigation vers la page des alertes
  }
}