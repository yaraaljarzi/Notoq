import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'info.dart';
import 'package:http/http.dart' as http;

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

void main() => runApp(SignupPage());

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String userId = '';

  Future<void> signUp(String name, String email, String password) async {
    final url = Uri.parse('http://192.168.100.10/TTS/signup.php');
    final response = await http.post(url, body: {
      'user_name': name,
      'user_email': email,
      'user_password': password,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          userId = data['user_id'].toString();
        });
        print('User ID: $userId');

        // Navigate to the next page here
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpeechPage(userId: userId),
          ),
        );
      } else {
        String errorMessage = data['message'];
        if (errorMessage == 'Email is already taken') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Color(beige),
              title: Text(
                'خطأ',
                style: GoogleFonts.notoKufiArabic(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Color(blue),
                ),
                textAlign: TextAlign.center,
              ),
              content: Text(
                "الايميل مأخوذ بالفعل",
                style: GoogleFonts.notoKufiArabic(
                  fontSize: 20.0,
                  color: Color(blue),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Color(blue)),
                  ),
                  child: Text(
                    'حسنا',
                    style: TextStyle(
                      color: Color(beige),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          print('Error: $errorMessage');
        }
      }
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  String getPasswordStrength(String password) {
    final RegExp uppercaseRegex = RegExp(r'[A-Z]');
    final RegExp lowercaseRegex = RegExp(r'[a-z]');
    final RegExp numberRegex = RegExp(r'\d');
    final RegExp symbolRegex = RegExp(r'[!@#\$%\^&\*()_+{}\[\]:;<>,.?\/\\|-]');

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(uppercaseRegex)) strength++;
    if (password.contains(lowercaseRegex)) strength++;
    if (password.contains(numberRegex)) strength++;
    if (password.contains(symbolRegex)) strength++;

    if (strength == 0) {
      return '';
    } else if (strength == 1) {
      return 'ضعيفة';
    } else if (strength == 2 || strength == 3) {
      return 'متوسطة';
    } else {
      return 'قوية';
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  child: Text(
                    "اسم المستخدم",
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 28,
                      color: Color(blue),
                      fontWeight: FontWeight.bold,
                      height: 2.5,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء ادخال اسمك';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'الاسم ',
                    labelStyle: TextStyle(
                      color: Color(blue),
                    ),
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
                  ),
                  autofocus: true,
                ),
                SizedBox(height: 16),
                Container(
                  child: Text(
                    "البريد الالكتروني",
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 28,
                      color: Color(blue),
                      fontWeight: FontWeight.bold,
                      height: 2.5,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء ادخال البريد الالكتروني';
                    } else if (!isValidEmail(value)) {
                      return 'الرجاء ادخال بريد الكتروني صحيح';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'البريد الالكتروني',
                    labelStyle: TextStyle(
                      color: Color(blue),
                    ),
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
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  child: Text(
                    "كلمة السر",
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 28,
                      color: Color(blue),
                      fontWeight: FontWeight.bold,
                      height: 2.5,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء ادخال كلمة السر';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة السر',
                    labelStyle: TextStyle(
                      color: Color(blue),
                    ),
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
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 16),
                Container(
                  child: Text(
                    getPasswordStrength(_passwordController.text),
                    style: TextStyle(
                      color: getPasswordStrength(
                          _passwordController.text) ==
                          'ضعيفة'
                          ? Colors.red
                          : getPasswordStrength(_passwordController.text) ==
                          'متوسطة'
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 30.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Color(blue)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(5.0),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await signUp(
                          _nameController.text.trim(),
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        'سجّل',
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
