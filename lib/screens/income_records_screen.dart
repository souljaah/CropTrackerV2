// lib/screens/income_records_screen.dart
import 'package:flutter/material.dart';
import '../models/income_record.dart';
import '../services/storage_service.dart';

class IncomeRecordsScreen extends StatefulWidget {
  final StorageService storageService;
  final Function(List<IncomeRecord>) onRecordsUpdated;

  const IncomeRecordsScreen({
    Key? key,
    required this.storageService,
    required this.onRecordsUpdated,
  }) : super(key: key);

  @override
  _IncomeRecordsScreenState createState() => _IncomeRecordsScreenState();
}

class _IncomeRecordsScreenState extends State<IncomeRecordsScreen> {
  List<IncomeRecord> incomeRecords = [];
  final _formKey = GlobalKey<FormState>();
  final cropNameController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedSection = 'Section A';
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadIncomeRecords();
  }
  
  Future<void> _loadIncomeRecords() async {
    setState(() {
      isLoading = true;
    });
    
    final records = await widget.storageService.loadIncomeRecords();
    
    setState(() {
      incomeRecords = records;
      isLoading = false;
    });
  }
  
  // Helper function to convert string with commas to double
  double parseAmountString(String amount) {
    // Remove all commas and convert to double
    return double.parse(amount.replaceAll(',', ''));
  }
  
  Future<void> _addIncomeRecord() async {
    if (_formKey.currentState!.validate()) {
      final newRecord = IncomeRecord(
        cropName: cropNameController.text,
        section: selectedSection,
        amount: parseAmountString(amountController.text),
        date: DateTime.now(),
        description: descriptionController.text.isEmpty ? null : descriptionController.text,
      );
      
      setState(() {
        incomeRecords.add(newRecord);
      });
      
      // Save updated records
      await widget.storageService.saveIncomeRecords(incomeRecords);
      
      // Notify parent about the update
      widget.onRecordsUpdated(incomeRecords);
      
      // Clear form
      cropNameController.clear();
      amountController.clear();
      descriptionController.clear();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Income record added successfully')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Records'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: cropNameController,
                          decoration: InputDecoration(labelText: 'Crop Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a crop name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedSection,
                          decoration: InputDecoration(labelText: 'Section'),
                          items: ['Section A', 'Section B', 'Section C']
                              .map((section) => DropdownMenuItem(
                                    value: section,
                                    child: Text(section),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSection = value!;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount (₱)',
                            hintText: 'Example: 1,000 or 1000',
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            
                            // Try to parse the value after removing commas
                            try {
                              parseAmountString(value);
                              return null;
                            } catch (e) {
                              return 'Please enter a valid number';
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'Enter additional details',
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _addIncomeRecord,
                          child: Text('Add Income Record'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: incomeRecords.isEmpty
                        ? Center(child: Text('No income records added yet'))
                        : ListView.builder(
                            itemCount: incomeRecords.length,
                            itemBuilder: (context, index) {
                              final record = incomeRecords[index];
                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    record.cropName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${record.section}'),
                                      if (record.description != null)
                                        Text(
                                          record.description!,
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₱${record.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                      Text(
                                        '${record.date.day}/${record.date.month}/${record.date.year}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
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
  
  @override
  void dispose() {
    cropNameController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}