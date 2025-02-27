import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizapp/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminQuizzesPage extends StatefulWidget {
  @override
  _AdminQuizzesPageState createState() => _AdminQuizzesPageState();
}

class _AdminQuizzesPageState extends State<AdminQuizzesPage> {
  List quizzes = [];

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> fetchQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("https://quizapp-backend-kkva.onrender.com/api/quizzes"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "$token",
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

  Future<void> createQuiz(String title, int duration, int score) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("https://quizapp-backend-kkva.onrender.com/api/quizzes"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "$token",
      },
      body: jsonEncode({
        "title": title,
        "numberOfQuestions": 0,
        "totalScore": score,
        "duration": duration,
      }),
    );

    if (response.statusCode == 201) {
      final newQuiz = jsonDecode(response.body)["quiz"];
      setState(() {
        quizzes.add(newQuiz);
      });
    } else {
      print("Failed to create quiz: ${response.body}");
    }
  }

  void showCreateQuizDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController durationController = TextEditingController();
    TextEditingController scoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Create Quiz",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(titleController, "Quiz Title"),
              _buildTextField(durationController, "Duration (min)",
                  isNumber: true),
              _buildTextField(scoreController, "Total Score", isNumber: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                String title = titleController.text.trim();
                int? duration = int.tryParse(durationController.text);
                int? score = int.tryParse(scoreController.text);

                if (title.isNotEmpty && duration != null && score != null) {
                  createQuiz(title, duration, score);
                  Navigator.pop(context);
                }
              },
              child: Text("Create", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Manage Quizzes"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: quizzes.isEmpty
            ? Center(
                child: Text(
                  "No quizzes available. Add a new quiz!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      title: Text(
                        quizzes[index]["title"],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text("Score: ${quizzes[index]["totalScore"]}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54)),
                          Text("Duration: ${quizzes[index]["duration"]} min",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: showCreateQuizDialog,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
