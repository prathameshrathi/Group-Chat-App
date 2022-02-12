import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/widgets/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flash_chat/validation.dart';

class LoginScreen extends StatefulWidget {
  static const id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  bool showSpinner = false;
  bool validEmail = true;
  bool validPass = true;
  bool hasEmail = true;
  bool hasPass = true;
  bool userNotFound=false;
  bool wrongPass=false;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                  setState(() {
                    userNotFound = false;
                    validEmail = Validation().validEmail(email);
                  });
                },
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                decoration: validEmail
                    ? kTextFieldDecoration.copyWith(
                        hintText: 'Enter your email')
                    : kTextFieldDecoration.copyWith(
                        hintText: 'Enter your email',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                          borderRadius: BorderRadius.all(
                            Radius.circular(32.0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
              ),
              Visibility(
                visible: !validEmail,
                child: Container(
                    margin: EdgeInsets.only(top: 5),
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Please enter valid email address.',
                      style: TextStyle(color: Colors.red),
                    )),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                  setState(() {
                    wrongPass = false;
                    validPass = Validation().validPass(password);
                  });
                },
                textAlign: TextAlign.center,
                obscureText: true,
                decoration: validPass
                    ? kTextFieldDecoration.copyWith(
                        hintText: 'Enter your password')
                    : kTextFieldDecoration.copyWith(
                        hintText: 'Enter your password',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
              ),
              Visibility(
                visible: !validPass,
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Password must have more than 5 characters.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              Visibility(
                visible: userNotFound||wrongPass,
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.only(left: 20),
                  child: userNotFound? Text(
                    'Could not find the user 🙁',
                    style: TextStyle(color: Colors.red,fontSize: 15),
                  ):Text(
                    'Incorrect password 🤕',
                    style: TextStyle(color: Colors.red,fontSize: 15),
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                text: 'Log In',
                colour: Colors.lightBlueAccent,
                onTap: () async {
                  setState(() {
                    if(email==null)
                      validEmail=false;
                    if(password==null)
                      validPass=false;
                    if (!validEmail || !validPass) return;
                    showSpinner = true;
                  });
                  if (validEmail && validPass) {
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      if (user != null) {
                        Navigator.pushNamed(context, ChatScreen.id);
                      }
                    } catch (e) {
                      if(e.code.toString()=="user-not-found"){
                        userNotFound=true;
                      }
                      else if(e.code.toString()=="wrong-password"){
                        wrongPass=true;
                      }
                    }
                  }
                  setState(() {
                    showSpinner = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
