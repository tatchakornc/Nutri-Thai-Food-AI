import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiRecognitionServiceProvider = Provider<AIFoodRecognitionService>((ref) {
  return GeminiAIFoodRecognitionService();
});

class AIRecognitionResult {
  final bool success;
  final List<DetectedFoodItem> detectedItems;
  final String? errorMessage;

  const AIRecognitionResult({
    required this.success,
    required this.detectedItems,
    this.errorMessage,
  });

  factory AIRecognitionResult.success(List<DetectedFoodItem> items) {
    return AIRecognitionResult(
      success: true,
      detectedItems: items,
    );
  }

  factory AIRecognitionResult.failure(String message) {
    return AIRecognitionResult(
      success: false,
      detectedItems: const [],
      errorMessage: message,
    );
  }
}

class DetectedFoodItem {
  final String detectedName;
  final double confidence;
  final String? matchedFoodId;
  final String? matchedFoodNameTh;

  const DetectedFoodItem({
    required this.detectedName,
    required this.confidence,
    this.matchedFoodId,
    this.matchedFoodNameTh,
  });

  factory DetectedFoodItem.fromMap(Map<String, dynamic> map) {
    return DetectedFoodItem(
      detectedName: (map['detectedName'] ?? '').toString(),
      confidence: map['confidence'] is num
          ? (map['confidence'] as num).toDouble()
          : 0.7,
      matchedFoodId: map['matchedFoodId']?.toString(),
      matchedFoodNameTh: map['matchedFoodNameTh']?.toString(),
    );
  }
}

abstract class AIFoodRecognitionService {
  Future<AIRecognitionResult> recognizeFood({
    File? imageFile,
    Uint8List? imageBytes,
    String mimeType,
  });
}

class GeminiAIFoodRecognitionService implements AIFoodRecognitionService {
  final FirebaseFunctions _functions;

  GeminiAIFoodRecognitionService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  @override
  Future<AIRecognitionResult> recognizeFood({
    File? imageFile,
    Uint8List? imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      Uint8List bytes;

      if (imageBytes != null) {
        bytes = imageBytes;
      } else if (imageFile != null) {
        bytes = await imageFile.readAsBytes();
      } else {
        return AIRecognitionResult.failure('ไม่พบรูปภาพ');
      }

      final base64Image = base64Encode(bytes);

      final callable = _functions.httpsCallable('analyzeFoodImage');

      final response = await callable.call({
        'imageBase64': base64Image,
        'mimeType': mimeType,
      }).timeout(const Duration(seconds: 60));

      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['success'] != true) {
        return AIRecognitionResult.failure(
          data['errorMessage']?.toString() ?? 'AI วิเคราะห์รูปไม่สำเร็จ',
        );
      }

      final rawItems = data['detectedItems'];

      if (rawItems is! List) {
        return AIRecognitionResult.failure('รูปแบบข้อมูลจาก AI ไม่ถูกต้อง');
      }

      final items = rawItems
          .map(
            (item) => DetectedFoodItem.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .where((item) => item.detectedName.trim().isNotEmpty)
          .toList();

      if (items.isEmpty) {
        return AIRecognitionResult.failure('AI ไม่พบอาหารในรูป');
      }

      return AIRecognitionResult.success(items);
    } catch (e) {
      return AIRecognitionResult.failure('เรียก AI ไม่สำเร็จ: $e');
    }
  }
}