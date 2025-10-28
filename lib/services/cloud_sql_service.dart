import 'package:mysql1/mysql1.dart';

class CloudSQLService {
  static Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: 'your-cloud-sql-ip',
      port: 3306,
      user: 'poolmaster-user',
      password: 'your-password',
      db: 'poolmaster_db',
    );
    
    return await MySqlConnection.connect(settings);
  }

  static Future<void> initializeDatabase() async {
    final conn = await getConnection();
    
    await conn.query('''
      CREATE TABLE IF NOT EXISTS pool_analytics (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pool_id VARCHAR(255) NOT NULL,
        date DATE NOT NULL,
        avg_temperature DECIMAL(4,2),
        avg_ph DECIMAL(3,2),
        total_energy_consumption DECIMAL(8,2),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    await conn.close();
  }
}