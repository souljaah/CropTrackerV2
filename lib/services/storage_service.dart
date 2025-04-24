// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop.dart';
import '../models/income_record.dart';

class StorageService {
  // Save crops to local storage
  Future<void> saveCrops(List<Crop> crops) async {
    final prefs = await SharedPreferences.getInstance();
    final cropsJson = crops.map((crop) => {
      'name': crop.name,
      'section': crop.section,
      'year': crop.year,
    }).toList();
    
    await prefs.setString('crops', jsonEncode(cropsJson));
  }
  
  // Load crops from local storage
  Future<List<Crop>> loadCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final cropsString = prefs.getString('crops');
    
    if (cropsString == null) return [];
    
    final cropsJson = jsonDecode(cropsString) as List;
    return cropsJson.map((cropJson) => Crop(
      name: cropJson['name'],
      section: cropJson['section'],
      year: cropJson['year'],
    )).toList();
  }
  
  // Save income records to local storage
  Future<void> saveIncomeRecords(List<IncomeRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = records.map((record) => {
      'cropName': record.cropName,
      'section': record.section,
      'amount': record.amount,
      'date': record.date.toIso8601String(),
      'description': record.description,
    }).toList();
    
    await prefs.setString('incomeRecords', jsonEncode(recordsJson));
  }
    
  Future<List<IncomeRecord>> loadIncomeRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsString = prefs.getString('incomeRecords');
    
    if (recordsString == null) return [];
    
    final recordsJson = jsonDecode(recordsString) as List;
    return recordsJson.map((recordJson) => IncomeRecord(
      cropName: recordJson['cropName'],
      section: recordJson['section'],
      amount: recordJson['amount'].toDouble(),
      date: DateTime.parse(recordJson['date']),
      description: recordJson['description'],
    )).toList();
  }
}