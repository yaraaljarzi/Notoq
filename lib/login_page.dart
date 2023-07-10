import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'inputmethods_ar.dart';


const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

class LoginPage extends StatefulWidget {


  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String userId = '';

  Future<void> userLogin() async {
    bool loginSuccess = false;
    bool mysqlSuccess = false;
    var url = Uri.parse(
        'http://192.168.100.10/TTS/login.php'); // Replace with your server URL

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text,
          'password': passwordController.text
        }),
      );

      if (response.statusCode == 200) {
        var responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          // Login successful, set loginSuccess to true
          loginSuccess = true;
          // Login successful, retrieve the user ID
          userId = responseJson['user_id'];
          setState(() {
            userId = userId;
          });
          print('Succeed');
          print('User ID: $userId'); // Print the value of userId
        } else {
          // Login failed, display an error message
          print('Failed');
        }
      } else {
        print('Login Failed');
        // Login failed, do something
      }
    } catch (e) {
      print('Exception occurred during login: $e');
    }

    try {
      // MySQL connection code here

      // If mysql connection succeeded, set mysqlSuccess to true
      mysqlSuccess = true;
    } catch (e) {
      print('Exception occurred during mysql connection: $e');
    }

    if (loginSuccess) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => inputmethods_ar(userId: userId)));
    } else {
      print('The email or the Password is wrong');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(beige),
            title: Text(
              'فشل تسجيل الدخول',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoKufiArabic(
                fontSize: 32,
                color: Color(blue),
                fontWeight: FontWeight.bold,
                height: 2.5,
              ),
            ),
            content: Text(
              'البريد الالكتروني او كلمة السر التي تم ادخالها غير صحيحة',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoKufiArabic(
                fontSize: 24,
                color: Color(blue),
                fontWeight: FontWeight.bold,
                height: 2.5,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text(
                  'حسنا',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 28,
                    color: Color(beige),
                    fontWeight: FontWeight.bold,
                    height: 2.5,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Color(blue),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(5.0),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(beige),
      ),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Color(blue),
              iconSize: 32,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      'أهلاً وسهلاً مجدداً',
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 40.0,
                        color: Color(blue),
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                    child: TextField(
                      controller: emailController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'البريد الإلكتروني',
                        filled: true,
                        fillColor: Color(beige),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color(blue),
                            width: 3.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color(blue),
                            width: 3.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color(blue),
                            width: 3.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10.0),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 3.0,
                          ),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                        ),
                        errorMaxLines: 2,
                        suffixIcon: Icon(Icons.email),
                        prefixIcon: Icon(Icons.person),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                        alignLabelWithHint: true,
                      ),
                      autofocus: true,
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                    child: TextField(
                      controller: passwordController,
                      textAlign: TextAlign.right,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'كلمة السر',
                        filled: true,
                        fillColor: Color(beige),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color(blue),
                            width: 3.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color(blue),
                            width: 3.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color(blue),
                            width: 3.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10.0),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 3.0,
                          ),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                        ),
                        errorMaxLines: 2,
                        prefixIcon: Icon(
                          Icons.lock,
                        ),
                        suffixIcon: Icon(
                          Icons.visibility_off,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Color(blue),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        elevation: MaterialStateProperty.all(5.0),
                      ),
                      onPressed: () {
                        // Call userLogin when login button is pressed
                        userLogin();
                      },
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          'تسجيل الدخول',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 28,
                            color: Color(beige),
                            fontWeight: FontWeight.bold,
                            height: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
