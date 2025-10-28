import 'package:cloud_firestore/cloud_firestore.dart';

class RealFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer les données de la piscine en temps réel
  Stream<DocumentSnapshot> getPoolData(String poolId) {
    return _firestore.collection('pools').doc(poolId).snapshots();
  }

  // Récupérer l'historique des données
  Stream<QuerySnapshot> getPoolHistory(String poolId) {
    return _firestore
        .collection('pools')
        .doc(poolId)
        .collection('sensor_data')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // Récupérer les alertes
  Stream<QuerySnapshot> getAlerts(String poolId) {
    return _firestore
        .collection('pools')
        .doc(poolId)
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Mettre à jour l'état de la pompe
  Future<void> updatePumpStatus(String poolId, bool status) async {
    await _firestore.collection('pools').doc(poolId).update({
      'pump_status': status,
      'last_update': FieldValue.serverTimestamp(),
    });
  }

  // Ajouter des données de capteur simulées
  Future<void> addSimulatedSensorData(String poolId) async {
    final random = DateTime.now().millisecondsSinceEpoch;
    
    final data = {
      'temperature': 24.0 + (random % 10) * 0.2,
      'ph': 7.0 + (random % 10) * 0.02,
      'water_level': 80.0 + (random % 20),
      'pump_status': true,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Mettre à jour les données actuelles
    await _firestore.collection('pools').doc(poolId).update(data);
    
    // Ajouter à l'historique
    await _firestore
        .collection('pools')
        .doc(poolId)
        .collection('sensor_data')
        .add(data);

    // Vérifier et créer des alertes si nécessaire
    await _checkAndCreateAlerts(poolId, data);
  }

  // Vérifier et créer des alertes
  Future<void> _checkAndCreateAlerts(String poolId, Map<String, dynamic> data) async {
    final double? ph = data['ph'];
    final double? waterLevel = data['water_level'];
    final double? temperature = data['temperature'];

    List<String> alerts = [];

    if (ph != null && (ph < 6.5 || ph > 8.0)) {
      alerts.add('Niveau de pH dangereux: ${ph.toStringAsFixed(1)}');
    }

    if (waterLevel != null && waterLevel < 50) {
      alerts.add('Niveau d\'eau critique: ${waterLevel.toStringAsFixed(0)}%');
    }

    if (temperature != null && (temperature < 18 || temperature > 32)) {
      alerts.add('Température extrême: ${temperature.toStringAsFixed(1)}°C');
    }

    for (final alertMessage in alerts) {
      await _firestore
          .collection('pools')
          .doc(poolId)
          .collection('alerts')
          .add({
            'message': alertMessage,
            'timestamp': FieldValue.serverTimestamp(),
            'resolved': false,
            'type': _getAlertType(alertMessage),
          });
    }
  }

  String _getAlertType(String message) {
    if (message.contains('pH')) return 'ph_alert';
    if (message.contains('eau')) return 'water_alert';
    if (message.contains('Température')) return 'temperature_alert';
    return 'general_alert';
  }

  // Résoudre une alerte
  Future<void> resolveAlert(String poolId, String alertId) async {
    await _firestore
        .collection('pools')
        .doc(poolId)
        .collection('alerts')
        .doc(alertId)
        .update({
          'resolved': true,
          'resolved_at': FieldValue.serverTimestamp(),
        });
  }

  // Simuler des données en continu (pour la démo)
  void startDataSimulation(String poolId) {
    // Simuler des données toutes les 10 secondes
    Future.delayed(Duration(seconds: 10), () {
      addSimulatedSensorData(poolId);
      startDataSimulation(poolId); // Rappel récursif
    });
  }
}