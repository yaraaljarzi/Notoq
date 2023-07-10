import 'package:flutter/material.dart';
import 'login_en.dart';
import 'signup_en.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mainpage.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

void main() => runApp(LogoPage_en());

class LogoPage_en extends StatefulWidget {
  @override
  _LogoPageState createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage_en> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(beige),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color _loginButtonColor = Color(beige);
  Color _signupButtonColor = Color(beige);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Color(beige),
        ),
        home: Scaffold(
          backgroundColor: Color(beige),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.language),
                color: Color(blue),
                iconSize: 32,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogoPage()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 25.0),
                  child: CircleAvatar(
                    radius: 175.0,
                    backgroundImage: AssetImage('assets/LOGO.png'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: SizedBox(
                    height: 65,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage_en()),
                          );
                        },
                        child: Text('Login',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              fontSize: 28,
                              color: Color(blue),
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            )),
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return _loginButtonColor.withOpacity(0.5);
                              }
                              return _loginButtonColor;
                            },
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Color(blue),
                                width: 3.0,
                              ),
                            ),
                          ),
                          shadowColor: MaterialStateProperty.all(
                            Color(blue),
                          ),
                          elevation: MaterialStateProperty.all(5.0),
                        )),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: SizedBox(
                    height: 65,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage_en()),
                          );
                        },
                        child: Text('SignUp',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              fontSize: 28,
                              color: Color(blue),
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            )),
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return _signupButtonColor.withOpacity(0.5);
                              }
                              return _signupButtonColor;
                            },
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Color(blue),
                                width: 3.0,
                              ),
                            ),
                          ),
                          shadowColor: MaterialStateProperty.all(
                            Color(blue),
                          ),
                          elevation: MaterialStateProperty.all(5.0),
                        )),
                  ),
                ),
              ],
            ),
          ),)
        ));
  }
}
