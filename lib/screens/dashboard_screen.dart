// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/crop.dart';
import '../models/income_record.dart';


class DashboardScreen extends StatelessWidget {
  final List<Crop> crops;
  final List<IncomeRecord> incomeRecords;
  
  const DashboardScreen({
    Key? key, 
    required this.crops, 
    required this.incomeRecords
  }) : super(key: key);
  
  double getTotalIncome() {
    return incomeRecords.fold(0, (sum, record) => sum + record.amount);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green[100],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Income Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Total Income: ₱${getTotalIncome().toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Records: ${incomeRecords.length}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Current Crop Assignments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: crops.isEmpty
                  ? Center(child: Text('No crops assigned yet'))
                  : ListView.builder(
                      itemCount: crops.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.grass, color: Colors.green),
                            title: Text(crops[index].name),
                            subtitle: Text(crops[index].section),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}