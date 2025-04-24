import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/crop_records_screen.dart';
import 'screens/income_records_screen.dart';
import 'screens/reports_screen.dart';
import 'services/storage_service.dart';
import 'services/rotation_service.dart';
import 'models/crop.dart';
import 'models/income_record.dart';
import 'splash_screen.dart';

void main() {
  runApp(CropRotationApp());
}

class CropRotationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Rotation & Income Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storageService = StorageService();
  final RotationService _rotationService = RotationService();

  List<Crop> crops = [];
  List<IncomeRecord> incomeRecords = [];
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final loadedCrops = await _storageService.loadCrops();
    final loadedRecords = await _storageService.loadIncomeRecords();

    setState(() {
      crops = loadedCrops;
      incomeRecords = loadedRecords;
      _isInitialized = true;
    });
  }

  void _updateCrops(List<Crop> updatedCrops) {
    setState(() {
      crops = updatedCrops;
    });
  }

  void _updateIncomeRecords(List<IncomeRecord> updatedRecords) {
    setState(() {
      incomeRecords = updatedRecords;
    });
  }

  Widget _getScreen() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(
          crops: crops,
          incomeRecords: incomeRecords,
        );
      case 1:
        return CropRecordsScreen(
          storageService: _storageService,
          rotationService: _rotationService,
          onCropsUpdated: _updateCrops,
        );
      case 2:
        return IncomeRecordsScreen(
          storageService: _storageService,
          onRecordsUpdated: _updateIncomeRecords,
        );
      case 3:
        return ReportsScreen(
          incomeRecords: incomeRecords,
        );
      default:
        return DashboardScreen(
          crops: crops,
          incomeRecords: incomeRecords,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_isInitialized
          ? Center(child: CircularProgressIndicator())
          : _getScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grass),
            label: 'Crops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Income',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
