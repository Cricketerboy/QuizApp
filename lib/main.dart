import 'package:flutter/material.dart';
import 'package:quizapp/model/question_model.dart';
import 'package:quizapp/data/question_list.dart';
import 'package:quizapp/screns/result_screen.dart';

void main() => runApp(MaterialApp(
      title: 'QuizApp',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
      },
    ));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color maincolor = Color(0xFF252c4a);
  Color secondcolor = Color(0xFF117eeb);
  PageController? _controller = PageController(initialPage: 0);
  bool isPressed = false;
  Color trueanswer = Colors.green;
  Color isWrong = Colors.red;
  Color btnColor = Color(0xFF117eeb);
  int score = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Quiz App'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      backgroundColor: maincolor,
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
          controller: _controller!,
          onPageChanged: (value) {
            setState(() {
              isPressed = false;
            });
          },
          itemCount: questions.length,
          itemBuilder: ((context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Question ${index + 1}/${questions.length}",
                    style: TextStyle(color: Colors.white, fontSize: 28.0),
                  ),
                ),
                Divider(
                  height: 8.0,
                  thickness: 1.0,
                  color: Colors.white,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  questions[index].question!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                  ),
                ),
                SizedBox(
                  height: 35.0,
                ),
                for (int i = 0; i < questions[index].answers!.length; i++)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 18.0),
                    child: MaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      onPressed: () {
                        setState(() {
                          isPressed = true;
                        });
                        if (questions[index]
                            .answers!
                            .entries
                            .toList()[i]
                            .value) {
                          score += 10;
                        } else {
                          score -= 10;
                        }
                      },
                      child: Text(
                        questions[index].answers!.keys.toList()[i],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      shape: StadiumBorder(),
                      color: isPressed
                          ? questions[index].answers!.entries.toList()[i].value
                              ? trueanswer
                              : isWrong
                          : secondcolor,
                    ),
                  ),
                SizedBox(
                  height: 50.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: isPressed
                          ? index + 1 == questions.length
                              ? () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ResultScreen(score)));
                                }
                              : () {
                                  _controller!.nextPage(
                                      duration: Duration(milliseconds: 100),
                                      curve: Curves.linear);
                                }
                          : null,
                      style: OutlinedButton.styleFrom(
                        shape: StadiumBorder(),
                        backgroundColor: Colors.orange,
                      ),
                      child: Text(
                        index + 1 == questions.length
                            ? "See Result"
                            : "Next Question",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
