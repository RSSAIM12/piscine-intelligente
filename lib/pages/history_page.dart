import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/real_auth_service.dart';
import '../services/real_firestore_service.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final RealAuthService _authService = RealAuthService();
  final RealFirestoreService _firestoreService = RealFirestoreService();
  late String poolId;

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
        stream: _firestoreService.getPoolHistory(poolId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun historique disponible',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les données apparaîtront bientôt',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          var historyData = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: historyData.length,
            itemBuilder: (context, index) {
              var data = historyData[index].data() as Map<String, dynamic>;
              var timestamp = (data['timestamp'] as Timestamp).toDate();
              
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.analytics, color: Colors.blue),
                  ),
                  title: Text(
                    '${data['temperature']?.toStringAsFixed(1) ?? '--'}°C | pH: ${data['ph']?.toStringAsFixed(1) ?? '--'}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Niveau eau: ${data['water_level']?.toStringAsFixed(0) ?? '--'}%',
                  ),
                  trailing: Text(
                    '${_formatTime(timestamp)}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}