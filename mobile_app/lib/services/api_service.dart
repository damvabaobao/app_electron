import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://10.0.2.2:8000';

  Future<PredictionApiResult> predict(List<double> featureVector) async {
    if (featureVector.length != 15) {
      throw ArgumentError(
        'Feature vector must have exactly 15 feature.'
        'Received: ${featureVector.length}',
      );
    }

    final url = Uri.parse('$baseUrl/predict');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'features': featureVector}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Prediction API error: '
        '${response.statusCode} - ${response.body}',
      );
    }
    final json = jsonDecode(response.body);
    return PredictionApiResult.fromJson(json);
  }
}

class PredictionApiResult {
  final String substance;
  final int classIndex;
  final double confidence;

  const PredictionApiResult({
    required this.substance,
    required this.classIndex,
    required this.confidence,
  });

  factory PredictionApiResult.fromJson(Map<String, dynamic> json) {
    return PredictionApiResult(
      substance: json['substance'] as String,
      classIndex: json['class_index'] as int,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
