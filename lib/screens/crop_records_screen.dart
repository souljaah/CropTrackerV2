// lib/screens/crop_records_screen.dart
import 'package:flutter/material.dart';
import '../models/crop.dart';
import '../services/storage_service.dart';
import '../services/rotation_service.dart';

class CropRecordsScreen extends StatefulWidget {
  final StorageService storageService;
  final RotationService rotationService;
  final Function(List<Crop>) onCropsUpdated;

  const CropRecordsScreen({
    Key? key,
    required this.storageService,
    required this.rotationService,
    required this.onCropsUpdated,
  }) : super(key: key);

  @override
  _CropRecordsScreenState createState() => _CropRecordsScreenState();
}

class _CropRecordsScreenState extends State<CropRecordsScreen> {
  List<Crop> crops = [];
  final _formKey = GlobalKey<FormState>();
  final cropNameController = TextEditingController();
  String selectedSection = 'Section A';
  bool isLoading = true;
  int currentYear = DateTime.now().year;
  
  @override
  void initState() {
    super.initState();
    _loadCrops();
  }
  
  Future<void> _loadCrops() async {
    setState(() {
      isLoading = true;
    });
    
    final loadedCrops = await widget.storageService.loadCrops();
    
    setState(() {
      crops = loadedCrops;
      isLoading = false;
    });
  }
  
  Future<void> _addCrop() async {
    if (_formKey.currentState!.validate()) {
      final newCrop = Crop(
        name: cropNameController.text,
        section: selectedSection,
        year: currentYear,
      );
      
      setState(() {
        crops.add(newCrop);
      });
      
      // Save updated crops
      await widget.storageService.saveCrops(crops);
      
      // Notify parent about the update
      widget.onCropsUpdated(crops);
      
      // Clear form
      cropNameController.clear();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Crop added successfully')),
      );
    }
  }
  
  Future<void> _rotateCrops() async {
    // Create dialog to confirm rotation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rotate Crops'),
        content: Text(
          'This will rotate all crops to the next section for the upcoming year. Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final rotatedCrops = widget.rotationService.rotateCrops(
                crops, 
                currentYear
              );
              
              setState(() {
                crops.addAll(rotatedCrops);
                currentYear = currentYear + 1;
              });
              
              // Save updated crops
              await widget.storageService.saveCrops(crops);
              
              // Notify parent about the update
              widget.onCropsUpdated(crops);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Crops rotated successfully')),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Filter crops to show only current year
    final currentYearCrops = crops.where((crop) => crop.year == currentYear).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.rotate_right),
            tooltip: 'Rotate Crops',
            onPressed: _rotateCrops,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Year: $currentYear',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: cropNameController,
                          decoration: InputDecoration(
                            labelText: 'Crop Name',
                            hintText: 'Enter crop name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a crop name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedSection,
                          decoration: InputDecoration(
                            labelText: 'Section',
                            border: OutlineInputBorder(),
                          ),
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
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _addCrop,
                          icon: Icon(Icons.add),
                          label: Text('Add Crop'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Current Crop Assignments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: currentYearCrops.isEmpty
                        ? Center(child: Text('No crops assigned for current year'))
                        : ListView.builder(
                            itemCount: currentYearCrops.length,
                            itemBuilder: (context, index) {
                              final crop = currentYearCrops[index];
                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: Icon(Icons.grass, color: Colors.green),
                                  title: Text(
                                    crop.name,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(crop.section),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      setState(() {
                                        crops.remove(crop);
                                      });
                                      
                                      // Save updated crops
                                      await widget.storageService.saveCrops(crops);
                                      
                                      // Notify parent about the update
                                      widget.onCropsUpdated(crops);
                                    },
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
    super.dispose();
  }
}