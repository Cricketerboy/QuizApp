import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizapp/model/question_model.dart';

class QuizService {
  static Future<List<QuestionModel>> fetchQuizData(String apiUrl) async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final questions = data['questions'] as List;
      return questions.map((q) {
        return QuestionModel(
          question: q['description'],
          answers: {
            for (var option in q['options'])
              option['description']: option['is_correct']
          },
        );
      }).toList();
    } else {
      throw Exception('Failed to load quiz data');
    }
  }
}
