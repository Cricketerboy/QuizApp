import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> quizData;
  final String quizId;
  final String token;

  QuizPage({required this.quizData, required this.quizId, required this.token});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Map<String, String> selectedAnswers = {};

  void submitQuiz() async {
    final response = await http.post(
      Uri.parse(
          "https://quizapp-backend-kkva.onrender.com/api/quizzes/${widget.quizId}/submit"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": widget.token,
      },
      body: jsonEncode({
        "responses": selectedAnswers.entries
            .map((entry) =>
                {"questionId": entry.key, "selectedOption": entry.value})
            .toList(),
      }),
    );

    if (response.statusCode == 200) {
      print("Quiz submitted successfully!");
      Navigator.pop(context); // Go back to dashboard
    } else {
      print("Failed to submit quiz: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quizData["quizTitle"])),
      body: ListView.builder(
        itemCount: widget.quizData["questions"].length,
        itemBuilder: (context, index) {
          var question = widget.quizData["questions"][index];
          return Card(
            child: ListTile(
              title: Text(question["questionText"]),
              subtitle: Column(
                children: question["options"].map<Widget>((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedAnswers[question["id"]],
                    onChanged: (value) {
                      setState(() {
                        selectedAnswers[question["id"]] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: submitQuiz,
        label: Text("Submit Quiz"),
        icon: Icon(Icons.send),
      ),
    );
  }
}
