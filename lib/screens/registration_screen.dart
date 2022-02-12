import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/widgets/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flash_chat/validation.dart';

class RegistrationScreen extends StatefulWidget {
  static const id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  bool validEmail = true;
  bool validPass = true;
  bool hasEmail = true;
  bool hasPass = true;
  bool userDuplicate=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
                    userDuplicate = false;
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
                visible: userDuplicate,
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Account with this email id already exists 😏',
                    style: TextStyle(color: Colors.red,fontSize: 15),
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                text: 'Register',
                colour: Colors.blueAccent,
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
                    final user = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                  } catch (e) {
                    if(e.code.toString()=="email-already-in-use"){
                      userDuplicate =true;
                    }
                    print(e);
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
