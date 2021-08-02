import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/widgets/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/widgets/rounded_button.dart';

import '../constants.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                height: 200.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                //Do something with the user input.
                email = value;
              },
              decoration:
                  kTextFieldDecoration.copyWith(hintText: 'Enter your Email'),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              textAlign: TextAlign.center,
              obscureText: true,
              onChanged: (value) {
                //Do something with the user input.
                password = value;
              },
              style: TextStyle(color: Colors.black),
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your Password'),
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              title: 'Login',
              onPress: () async {
                try {
                  final newUser = await _auth.signInWithEmailAndPassword(
                      email: email!, password: password!);
                  if (newUser.user != null) {
                    Navigator.pushNamed(context, ChatScreen.id);
                  } else {
                    showAlertDialog(context, "Email or Password are invalid!");
                  }
                } catch (e) {
                  print("Error =======$e");
                  showAlertDialog(context, "Email or Password are invalid!");
                }
              },
              color: Colors.lightBlueAccent,
            ),
          ],
        ),
      ),
    );
  }

  // void showAlertDialog(BuildContext context, String message) {
  //   // set up the AlertDialog
  //   showDialog<String>(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       title: const Text(
  //         'Error',
  //         style: TextStyle(color: Colors.black),
  //       ),
  //       content: Text(
  //         message,
  //         style: TextStyle(color: Colors.black),
  //       ),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, 'OK'),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
