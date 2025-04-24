import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'lib/assets/1.webp',
      'title': 'Welcome to Crop Tracker',
      'description': 'Track your crops and income effortlessly. Keep everything organized in one place!',
    },
    {
      'image': 'lib/assets/2.webp',
      'title': 'Assign Crops',
      'description': 'Easily assign crops to different classes and record them with just a few taps.',
    },
    {
      'image': 'lib/assets/3.webp',
      'title': 'Monitor Income',
      'description': 'Track the earnings from your crops and analyze productivity over time.',
    },
  ];

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, '/home'); // Navigate to HomePage
  }

  @override
  Widget build(BuildContext context) {
    final data = onboardingData[currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    "Skip",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(data['image']!, height: 250),
                  SizedBox(height: 4),
                  Text(
                    data['title']!,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    data['description']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(onboardingData.length, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: currentIndex == index ? 24 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: currentIndex == index ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (currentIndex == onboardingData.length - 1) {
                  _finishOnboarding();
                } else {
                  setState(() => currentIndex++);
                }
              },
              child: Text(
                currentIndex == onboardingData.length - 1 ? "Get Started" : "Next",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
