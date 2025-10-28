// services/ml_service.dart
class MLService {
  // Prédiction de la qualité de l'eau basée sur les paramètres
  String predictWaterQuality(double temperature, double ph, double waterLevel) {
    double score = 0;
    
    // Score température (idéal: 25-28°C)
    if (temperature >= 24 && temperature <= 29) score += 40;
    else if (temperature >= 22 && temperature <= 31) score += 20;
    
    // Score pH (idéal: 7.2-7.6)
    if (ph >= 7.2 && ph <= 7.6) score += 40;
    else if (ph >= 6.8 && ph <= 8.0) score += 20;
    
    // Score niveau d'eau
    if (waterLevel >= 80) score += 20;
    else if (waterLevel >= 60) score += 10;
    
    if (score >= 80) return 'EXCELLENTE';
    if (score >= 60) return 'BONNE';
    if (score >= 40) return 'MOYENNE';
    return 'MAUVAISE';
  }

  // Détection d'anomalies
  Map<String, dynamic> detectAnomalies(double temperature, double ph, double waterLevel) {
    List<String> anomalies = [];
    
    if (ph < 6.5 || ph > 8.0) {
      anomalies.add('Niveau de pH dangereux');
    }
    if (temperature < 18 || temperature > 35) {
      anomalies.add('Température extrême');
    }
    if (waterLevel < 50) {
      anomalies.add('Niveau d\'eau critique');
    }
    
    return {
      'hasAnomalies': anomalies.isNotEmpty,
      'anomalies': anomalies,
      'riskLevel': _calculateRiskLevel(anomalies.length)
    };
  }

  String _calculateRiskLevel(int anomalyCount) {
    if (anomalyCount >= 3) return 'CRITIQUE';
    if (anomalyCount >= 2) return 'ÉLEVÉ';
    if (anomalyCount >= 1) return 'MODÉRÉ';
    return 'FAIBLE';
  }
}