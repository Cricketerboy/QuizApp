import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminParticipantsPage extends StatefulWidget {
  @override
  _AdminParticipantsPageState createState() => _AdminParticipantsPageState();
}

class _AdminParticipantsPageState extends State<AdminParticipantsPage> {
  List quizzes = [];
  List participants = [];
  Map<String, dynamic>? selectedParticipant;
  String selectedQuizId = "";
  String? token;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
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

  Future<void> fetchParticipants(String quizId) async {
    if (token == null) return;

    final response = await http.get(
      Uri.parse(
          "https://quizapp-backend-kkva.onrender.com/api/quizzes/$quizId/participants"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token!,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        participants = jsonDecode(response.body);
      });
    } else {
      print("Failed to fetch participants: ${response.body}");
    }
  }

  Future<void> fetchParticipantResponses(String userId, String username) async {
    if (token == null || selectedQuizId.isEmpty) return;

    final response = await http.get(
      Uri.parse(
          "https://quizapp-backend-kkva.onrender.com/api/quizzes/$selectedQuizId/response/$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token!,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        selectedParticipant = jsonDecode(response.body);
        selectedParticipant!["username"] = username; // Store username
      });
      showParticipantDetails();
    } else {
      print("Failed to fetch responses: ${response.body}");
    }
  }

  void showParticipantDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (selectedParticipant == null) {
          return Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 30,
                      child: Text(
                        selectedParticipant!["username"][0].toUpperCase(),
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      selectedParticipant!["username"],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text("Score",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(
                          "${selectedParticipant!["score"]}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text("Status",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(
                          "${selectedParticipant!["status"]}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Divider(),
              Text(
                "Responses:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedParticipant!["responses"].length,
                  itemBuilder: (context, index) {
                    var response = selectedParticipant!["responses"][index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        title: Text(
                          "Question ID: ${response["questionId"]}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Your Answer: ${response["selectedOption"]}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz Participants")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              isExpanded: true,
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
                  participants = [];
                  selectedParticipant = null;
                });
                fetchParticipants(value!);
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: participants.isEmpty
                  ? Center(
                      child: Text(
                        selectedQuizId.isEmpty
                            ? "Select a quiz to view participants"
                            : "No participants yet",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12),
                            title: Text(
                              participants[index]["username"],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                                Text("Score: ${participants[index]["score"]}"),
                            trailing: Text(
                              "Status: ${participants[index]["status"]}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue),
                            ),
                            onTap: () {
                              fetchParticipantResponses(
                                  participants[index]["userId"],
                                  participants[index]["username"]);
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
