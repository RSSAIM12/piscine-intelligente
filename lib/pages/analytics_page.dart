// pages/analytics_page.dart
import 'package:flutter/material.dart';
import '../services/ml_service.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final MLService _mlService = MLService();
  final Map<String, dynamic> _currentData;

  @override
  Widget build(BuildContext context) {
    final quality = _mlService.predictWaterQuality(
      _currentData['temperature'] ?? 25.0,
      _currentData['ph'] ?? 7.0,
      _currentData['water_level'] ?? 80.0
    );

    final anomalies = _mlService.detectAnomalies(
      _currentData['temperature'] ?? 25.0,
      _currentData['ph'] ?? 7.0,
      _currentData['water_level'] ?? 80.0
    );

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildQualityCard(quality),
            SizedBox(height: 16),
            _buildAnomaliesCard(anomalies),
            SizedBox(height: 16),
            _buildRecommendationsCard(quality, anomalies),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityCard(String quality) {
    Color color = _getQualityColor(quality);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Qualité de l\'eau', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Icon(Icons.water_drop, size: 50, color: color),
            SizedBox(height: 8),
            Text(quality, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality) {
      case 'EXCELLENTE': return Colors.green;
      case 'BONNE': return Colors.blue;
      case 'MOYENNE': return Colors.orange;
      case 'MAUVAISE': return Colors.red;
      default: return Colors.grey;
    }
  }
}