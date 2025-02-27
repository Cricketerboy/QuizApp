import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizapp/screens/login_page.dart';
import 'package:quizapp/screens/question_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String username = "";
  String? token;
  List quizzes = [];
  Map<String, dynamic>? selectedQuiz;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "User";
      token = prefs.getString("token");
    });
    print(token);
    fetchMyQuizzes();
  }

  Future<void> fetchMyQuizzes() async {
    if (token == null) return;

    final response = await http.get(
      Uri.parse(
          "https://quizapp-backend-kkva.onrender.com/api/quizzes/my-quizzes"),
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

  Future<void> startQuiz(String quizId) async {
    if (token == null) return;

    final response = await http.post(
      Uri.parse(
          "https://quizapp-backend-kkva.onrender.com/api/quizzes/$quizId/start"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token!,
      },
    );

    if (response.statusCode == 200) {
      fetchMyQuizzes();
      print("Quiz started!");
    } else {
      print("Failed to start quiz: ${response.body}");
    }
  }

  Future<void> startAndFetchQuiz(String quizId) async {
    if (token == null) return;

    final response = await http.post(
      Uri.parse(
          "https://quizapp-backend-kkva.onrender.com/api/quizzes/$quizId/start"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token!,
      },
    );

    if (response.statusCode == 200) {
      print("Quiz started!");
      fetchQuizQuestions(quizId);
    } else {
      print("Failed to start quiz: ${response.body}");
    }
  }

  Future<void> fetchQuizQuestions(String quizId) async {
    if (token == null) return;

    final response = await http.get(
      Uri.parse(
          "https://quizapp-backend-kkva.onrender.com/api/quizzes/$quizId/questions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token!,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        selectedQuiz = jsonDecode(response.body);
      });
      navigateToQuizPage(quizId);
    } else {
      print("Failed to fetch questions: ${response.body}");
    }
  }

  void navigateToQuizPage(String quizId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          quizData: selectedQuiz!,
          quizId: quizId,
          token: token!,
        ),
      ),
    );
  }

  Future<void> fetchQuizResponse(String quizId) async {
    if (token == null) return;

    final response = await http.get(
      Uri.parse(
          "https://quizapp-backend-kkva.onrender.com/api/quizzes/$quizId/response"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token!,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        selectedQuiz = jsonDecode(response.body);
      });
      showQuizDetails();
    } else {
      print("Failed to fetch responses: ${response.body}");
    }
  }

  void showQuizDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (selectedQuiz == null) {
          return Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  selectedQuiz!["quizTitle"],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Score:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Text(
                          "${selectedQuiz!["score"]}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Status:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Text(
                          selectedQuiz!["status"],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: selectedQuiz!["status"] == "Completed"
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Responses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedQuiz!["responses"].length,
                  itemBuilder: (context, index) {
                    var response = selectedQuiz!["responses"][index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Question ID: ${response["questionId"]}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Your Answer: ${response["selectedOption"]}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("username");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Dashboard"),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(
                username,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "My Quizzes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: quizzes.isEmpty
                  ? Center(
                      child: Text(
                        "No quizzes available",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        var quiz = quizzes[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12),
                            title: Text(
                              quiz["title"],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Duration: ${quiz["duration"]} mins"),
                                Text("Total Score: ${quiz["totalScore"]}"),
                              ],
                            ),
                            trailing: Text(
                              quiz["status"],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: quiz["status"] == "Completed"
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                            onTap: () {
                              if (quiz["status"] == "Not Started") {
                                startAndFetchQuiz(quiz["_id"]);
                              } else if (quiz["status"] == "In-Progress") {
                                fetchQuizQuestions(quiz["_id"]);
                              } else if (quiz["status"] == "Completed") {
                                fetchQuizResponse(quiz["_id"]);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
