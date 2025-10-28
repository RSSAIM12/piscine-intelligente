import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/real_auth_service.dart';
import '../services/real_firestore_service.dart';

class AlertsPage extends StatefulWidget {
  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final RealAuthService _authService = RealAuthService();
  final RealFirestoreService _firestoreService = RealFirestoreService();
  late String poolId;
  List<QueryDocumentSnapshot> _alerts = [];

  @override
  void initState() {
    super.initState();
    poolId = _authService.getCurrentUserPoolId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getAlerts(poolId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Aucune alerte',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tout fonctionne correctement',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          _alerts = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _alerts.length,
            itemBuilder: (context, index) {
              var alert = _alerts[index].data() as Map<String, dynamic>;
              var timestamp = (alert['timestamp'] as Timestamp).toDate();
              bool isResolved = alert['resolved'] ?? false;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                color: isResolved ? Colors.grey[100] : Colors.red[50],
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isResolved ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isResolved ? Icons.check : Icons.warning,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    alert['message'] ?? 'Alerte',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isResolved ? Colors.grey : Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    '${_formatDate(timestamp)}',
                  ),
                  trailing: isResolved
                      ? Text(
                          'Résolue',
                          style: TextStyle(color: Colors.green),
                        )
                      : ElevatedButton(
                          onPressed: () => _resolveAlert(_alerts[index].id),
                          child: Text('Résoudre'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _resolveAlert(String alertId) async {
    await _firestoreService.resolveAlert(poolId, alertId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alerte résolue'),
        backgroundColor: Colors.green,
      ),
    );
  }
}