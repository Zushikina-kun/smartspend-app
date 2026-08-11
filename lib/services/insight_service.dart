import 'llm_service.dart';

class InsightService {
  static Future<String> generateInsights(List<Map<String, dynamic>> expenses,
      {double? actualTotal}) async {
    return LLMService.analyzeInsights(expenses, actualTotal: actualTotal);
  }
}
