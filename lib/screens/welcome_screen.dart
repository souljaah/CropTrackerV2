// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/rotation_service.dart';
import '../services/storage_service.dart';
import 'crop_records_screen.dart';
import 'dashboard_screen.dart';
import 'income_records_screen.dart';
import 'reports_screen.dart';
import 'package:crop_trackerv1/models/crop.dart';
import 'package:crop_trackerv1/models/income_record.dart';

class WelcomeScreen extends StatefulWidget {
  final StorageService storageService;
  final RotationService rotationService;
  final List<Crop> crops;
  final List<IncomeRecord> incomeRecords;
  final void Function(List<Crop>) onCropsUpdated;
  final void Function(List<IncomeRecord>) onRecordsUpdated;

  const WelcomeScreen({
    Key? key,
    required this.storageService,
    required this.rotationService,
    required this.crops,
    required this.incomeRecords,
    required this.onCropsUpdated,
    required this.onRecordsUpdated,
  }) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isFirstLaunch = true;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _checkIfFirstLaunch();
  }
  
  Future<void> _checkIfFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    // For testing - uncomment this line to reset the onboarding state
    // await prefs.setBool('onboarding_completed', false);
    
    final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
    
    setState(() {
      _isFirstLaunch = !hasCompletedOnboarding;
      _isLoading = false;
    });
    
    print('Is first launch: $_isFirstLaunch'); // Debug print
  }
  
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    setState(() {
      _isFirstLaunch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking if it's first launch
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_isFirstLaunch) {
      return _OnboardingScreen(
        completeOnboarding: _completeOnboarding,
      );
    } else {
      return _MainScreen(
        storageService: widget.storageService,
        rotationService: widget.rotationService,
        crops: widget.crops,
        incomeRecords: widget.incomeRecords,
        onCropsUpdated: widget.onCropsUpdated,
        onRecordsUpdated: widget.onRecordsUpdated,
      );
    }
  }
}

class _OnboardingScreen extends StatefulWidget {
  final Function completeOnboarding;
  
  const _OnboardingScreen({
    Key? key,
    required this.completeOnboarding,
  }) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingPages = [
    {
      'image': 'lib/assets/1.webp',
      'title': 'Welcome to Crop Tracker',
      'description':
      'Track your crops and income effortlessly. Keep everything organized in one place!',
    },
    {
      'image': 'lib/assets/2.webp',
      'title': 'Assign Crops',
      'description':
      'Easily assign crops to different classes and record them with just a few taps.',
    },
    {
      'image': 'lib/assets/3.webp',
      'title': 'Monitor Income',
      'description':
      'Track the earnings from your crops and analyze productivity over time.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: TextButton(
                  onPressed: () => widget.completeOnboarding(),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingPages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _onboardingPages[index]['image']!,
                          height: 250,
                        ),
                        SizedBox(height: 32),
                        Text(
                          _onboardingPages[index]['title']!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _onboardingPages[index]['description']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicators
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingPages.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Colors.green : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _onboardingPages.length - 1 ? 'Get Started' : 'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainScreen extends StatelessWidget {
  final StorageService storageService;
  final RotationService rotationService;
  final List<Crop> crops;
  final List<IncomeRecord> incomeRecords;
  final void Function(List<Crop>) onCropsUpdated;
  final void Function(List<IncomeRecord>) onRecordsUpdated;

  const _MainScreen({
    Key? key,
    required this.storageService,
    required this.rotationService,
    required this.crops,
    required this.incomeRecords,
    required this.onCropsUpdated,
    required this.onRecordsUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Rotation & Income Tracker'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('lib/assets/4.png', height: 150),
              SizedBox(height: 30),
              Text(
                'Welcome to Crop Rotation & Income Tracker',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              _buildNavigationButton(
                context,
                'Crop Records',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CropRecordsScreen(
                      storageService: storageService,
                      rotationService: rotationService,
                      onCropsUpdated: onCropsUpdated,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                'Income Records',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncomeRecordsScreen(
                      storageService: storageService,
                      onRecordsUpdated: onRecordsUpdated,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                'Dashboard',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(
                      crops: crops,
                      incomeRecords: incomeRecords,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                'Reports',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportsScreen(
                      incomeRecords: incomeRecords,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, 
    String label, 
    VoidCallback onPressed
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}