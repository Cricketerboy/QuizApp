// import 'package:flutter/material.dart';
// import 'package:quizapp/screens/quiz_page.dart';

// class ResultScreen extends StatefulWidget {
//   final int score;

//   const ResultScreen(this.score, {super.key});

//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }

// class _ResultScreenState extends State<ResultScreen> {
//   @override
//   Widget build(BuildContext context) {
//     Color maincolor = Color(0xFF252c4a);
//     Color secondcolor = Color(0xFF117eeb);
//     return Scaffold(
//       backgroundColor: maincolor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Congratulations',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 40,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Text(
//               'See Your Result',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w200,
//               ),
//             ),
//             SizedBox(
//               height: 40.0,
//             ),
//             Text(
//               "${widget.score}",
//               style: TextStyle(
//                 color: Colors.yellowAccent,
//                 fontSize: 30.0,
//                 fontWeight: FontWeight.w300,
//               ),
//             ),
//             SizedBox(
//               height: 30.0,
//             ),
//             MaterialButton(
//               onPressed: () {
//                 Navigator.pushReplacement(context,
//                     MaterialPageRoute(builder: (context) => HomePage()));
//               },
//               shape: StadiumBorder(),
//               color: Colors.orange,
//               child: Text(
//                 'Play Again',
//                 style: TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
