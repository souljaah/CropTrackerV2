// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import '../models/income_record.dart';

class ReportsScreen extends StatelessWidget {
  final List<IncomeRecord> incomeRecords;
  
  const ReportsScreen({Key? key, required this.incomeRecords}) : super(key: key);
  
  Map<String, double> getIncomeBySection() {
    final Map<String, double> sectionTotals = {};
    
    for (var record in incomeRecords) {
      if (sectionTotals.containsKey(record.section)) {
        sectionTotals[record.section] = sectionTotals[record.section]! + record.amount;
      } else {
        sectionTotals[record.section] = record.amount;
      }
    }
    
    return sectionTotals;
  }
  
  @override
  Widget build(BuildContext context) {
    final sectionTotals = getIncomeBySection();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income by Section',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: sectionTotals.isEmpty
                  ? Center(child: Text('No data available'))
                  : ListView.builder(
                      itemCount: sectionTotals.length,
                      itemBuilder: (context, index) {
                        final section = sectionTotals.keys.elementAt(index);
                        final total = sectionTotals[section];
                        
                        return Card(
                          child: ListTile(
                            title: Text(section),
                            trailing: Text(
                              '₱${total!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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