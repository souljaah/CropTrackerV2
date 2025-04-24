// lib/services/rotation_service.dart
import '../models/crop.dart';

class RotationService {
  // Sections in preferred rotation order
  final List<String> sectionOrder = ['Section A', 'Section B', 'Section C'];
  
  List<Crop> rotateCrops(List<Crop> currentCrops, int currentYear) {
    // Filter crops for the current year
    final currentYearCrops = currentCrops
        .where((crop) => crop.year == currentYear)
        .toList();
    
    // Group crops by section
    final Map<String, List<String>> cropsBySection = {};
    for (var crop in currentYearCrops) {
      if (!cropsBySection.containsKey(crop.section)) {
        cropsBySection[crop.section] = [];
      }
      cropsBySection[crop.section]!.add(crop.name);
    }
    
    // Create new crops with rotated sections
    final List<Crop> rotatedCrops = [];
    for (int i = 0; i < sectionOrder.length; i++) {
      final currentSection = sectionOrder[i];
      final nextSection = sectionOrder[(i + 1) % sectionOrder.length];
      
      if (cropsBySection.containsKey(currentSection)) {
        for (var cropName in cropsBySection[currentSection]!) {
          rotatedCrops.add(Crop(
            name: cropName,
            section: nextSection,
            year: currentYear + 1,
          ));
        }
      }
    }
    
    return rotatedCrops;
  }
}