import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddQuestionPage extends StatefulWidget {
  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  List quizzes = [];
  String selectedQuizId = "";
  TextEditingController questionController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();
  TextEditingController correctAnswerController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  String? token;

  @override
  void initState() {
    super.initState();
    loadTokenAndFetchQuizzes();
  }

  Future<void> loadTokenAndFetchQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token");
    });
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    if (token == null) return;

    final response = await http.get(
      Uri.parse("https://quizapp-backend-kkva.onrender.com/api/quizzes"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token!,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        quizzes = jsonDecode(response.body);
      });
    } else {
      print("Failed to fetch quizzes: ${response.body}");
    }
  }

  Future<void> addQuestion() async {
    if (selectedQuizId.isEmpty ||
        questionController.text.isEmpty ||
        option1Controller.text.isEmpty ||
        option2Controller.text.isEmpty ||
        option3Controller.text.isEmpty ||
        option4Controller.text.isEmpty ||
        correctAnswerController.text.isEmpty ||
        marksController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(
          "https://quizapp-backend-kkva.onrender.com/api/quizzes/$selectedQuizId/questions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token!,
      },
      body: jsonEncode({
        "questionText": questionController.text,
        "options": [
          option1Controller.text,
          option2Controller.text,
          option3Controller.text,
          option4Controller.text
        ],
        "correctAnswer": correctAnswerController.text,
        "marks": int.parse(marksController.text),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Question added successfully!")),
      );
      questionController.clear();
      option1Controller.clear();
      option2Controller.clear();
      option3Controller.clear();
      option4Controller.clear();
      correctAnswerController.clear();
      marksController.clear();
    } else {
      print("Failed to add question: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Question")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Select Quiz",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        hint: Text("Select a Quiz"),
                        value: selectedQuizId.isEmpty ? null : selectedQuizId,
                        items: quizzes.map<DropdownMenuItem<String>>((quiz) {
                          return DropdownMenuItem<String>(
                            value: quiz["_id"].toString(),
                            child: Text(quiz["title"].toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedQuizId = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildTextField(questionController, "Enter Question"),
              _buildTextField(option1Controller, "Option 1"),
              _buildTextField(option2Controller, "Option 2"),
              _buildTextField(option3Controller, "Option 3"),
              _buildTextField(option4Controller, "Option 4"),
              _buildTextField(correctAnswerController, "Correct Answer"),
              _buildTextField(marksController, "Marks",
                  inputType: TextInputType.number),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: addQuestion,
                  child: Text(
                    "Add Question",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
