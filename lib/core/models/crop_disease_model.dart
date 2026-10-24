import 'dart:convert';

/// Represents the structured AI diagnostic outcome for a scanned crop leaf.
class CropDiseaseResult {
  final String id;
  final String cropName;
  final String diseaseName;
  final String confidence; // e.g., 'High (95%)', 'Moderate (75%)', 'Uncertain'
  final bool isClearImage; // false if image is blurry or not a plant leaf
  final String clarityFeedback; // guidance if image is unclear
  final List<String> symptoms;
  final String immediateSteps;
  final String preventionGuidance;
  final String organicTreatment;
  final String chemicalTreatment;
  final String expertConsultation;
  final DateTime scannedAt;
  final String? imagePath;
  final String? imageBase64;
  final bool isDemoData; // Rule 10: Clearly marks offline demo data vs real AI response

  const CropDiseaseResult({
    required this.id,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.isClearImage,
    required this.clarityFeedback,
    required this.symptoms,
    required this.immediateSteps,
    required this.preventionGuidance,
    required this.organicTreatment,
    required this.chemicalTreatment,
    required this.expertConsultation,
    required this.scannedAt,
    this.imagePath,
    this.imageBase64,
    this.isDemoData = false,
  });

  bool get isHealthy =>
      diseaseName.toLowerCase().contains('healthy') ||
      diseaseName.toLowerCase().contains('no disease');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'isClearImage': isClearImage,
      'clarityFeedback': clarityFeedback,
      'symptoms': symptoms,
      'immediateSteps': immediateSteps,
      'preventionGuidance': preventionGuidance,
      'organicTreatment': organicTreatment,
      'chemicalTreatment': chemicalTreatment,
      'expertConsultation': expertConsultation,
      'scannedAt': scannedAt.toIso8601String(),
      'imagePath': imagePath,
      'imageBase64': imageBase64,
      'isDemoData': isDemoData,
    };
  }

  factory CropDiseaseResult.fromMap(Map<String, dynamic> map) {
    return CropDiseaseResult(
      id: map['id'] as String? ?? 'scan_${DateTime.now().millisecondsSinceEpoch}',
      cropName: map['cropName'] as String? ?? 'Unknown Crop',
      diseaseName: map['diseaseName'] as String? ?? 'Undetected Condition',
      confidence: map['confidence'] as String? ?? 'Moderate',
      isClearImage: map['isClearImage'] as bool? ?? true,
      clarityFeedback: map['clarityFeedback'] as String? ?? '',
      symptoms: (map['symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      immediateSteps: map['immediateSteps'] as String? ?? '',
      preventionGuidance: map['preventionGuidance'] as String? ?? '',
      organicTreatment: map['organicTreatment'] as String? ?? '',
      chemicalTreatment: map['chemicalTreatment'] as String? ?? '',
      expertConsultation: map['expertConsultation'] as String? ??
          'Consult local Krishi Vigyan Kendra (KVK) extension officer for on-field verification.',
      scannedAt: map['scannedAt'] != null
          ? DateTime.tryParse(map['scannedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      imagePath: map['imagePath'] as String?,
      imageBase64: map['imageBase64'] as String?,
      isDemoData: map['isDemoData'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CropDiseaseResult.fromJson(String source) =>
      CropDiseaseResult.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Factory for unclear image feedback
  factory CropDiseaseResult.unclearImage({
    String? imagePath,
    String? imageBase64,
    String? feedback,
  }) {
    return CropDiseaseResult(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      cropName: 'Unidentified / Not a Crop Leaf',
      diseaseName: 'Image Unclear or Unrecognized',
      confidence: 'Low / Uncertain',
      isClearImage: false,
      clarityFeedback: feedback ??
          'The provided photo is too blurry, too dark, or does not clearly display an agricultural crop leaf. Please hold the camera 10–15 cm from the affected foliage in natural daylight and take a sharp photo.',
      symptoms: [
        'Insufficient visual detail to identify plant foliage',
        'Camera blur, glare, or subject out of focus',
      ],
      immediateSteps:
          'Tap "Retake Photo" and capture a clear close-up of the affected leaf showing both healthy and discolored areas.',
      preventionGuidance:
          'Ensure adequate daytime lighting without direct lens glare when photographing crops in the field.',
      organicTreatment: 'None until a clear diagnosis is made.',
      chemicalTreatment:
          'Do not apply chemical pesticides or fungicides without confirming the exact pest or pathogen.',
      expertConsultation:
          'If symptoms persist across the plot, take an actual physical sample to your nearest Krishi Vigyan Kendra (KVK) or Taluka Agriculture Officer.',
      scannedAt: DateTime.now(),
      imagePath: imagePath,
      imageBase64: imageBase64,
    );
  }
}
