import 'package:flutter/material.dart';
import 'package:flutterproject/profile.dart';
import 'package:flutterproject/speech_to_text_ar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_folder_ar.dart';
import 'inputmethods.dart';
import 'login_page.dart';
import 'mainpage.dart';
import 'paste_text.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'ScannerPage.dart';
import 'photo_upload_ar.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;
late CameraController _camera;

//void main() => runApp(inputmethods_ar());

class inputmethods_ar extends StatefulWidget {
  final String userId;

  inputmethods_ar({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<inputmethods_ar> {
  bool _showLanguageDrawer = false;
  final GlobalKey<ScaffoldState> _scaffoldKey1 = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey2 = GlobalKey<ScaffoldState>();

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _camera = CameraController(
      camera,
      ResolutionPreset.high,
    );
    await _camera.initialize();
  }

  @override
  Widget build(BuildContext context) {
    print('User ID: ${widget.userId}'); // Print the value of userId
    return MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Color(beige),
        ),
        home: Builder(
            builder: (context) => Scaffold(
                key: _scaffoldKey2,
                backgroundColor: Color(beige),
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
                  actions: [
                    IconButton(
                      icon: Icon(Icons.settings),
                      color: Color(blue),
                      iconSize: 32,
                      onPressed: () {
                        _scaffoldKey2.currentState?.openEndDrawer();
                      },
                    ),
                  ],
                ),
                endDrawer: Drawer(
                  backgroundColor: Color(beige),
                  child: _showLanguageDrawer
                      ? ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            DrawerHeader(
                              decoration: BoxDecoration(
                                color: Color(blue),
                              ),
                              child: Text(
                                'اختر اللغة',
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 30,
                                  color: Color(beige),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'الانجليزية',
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 25,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          inputmethods(userId: widget.userId)),
                                );
                              },
                            ),
                            ListTile(
                              title: Text(
                                'العربية',
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 25,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _showLanguageDrawer =
                                      false; // Hide the language drawer
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        )
                      : ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            DrawerHeader(
                              decoration: BoxDecoration(
                                color: Color(blue),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'الاعدادات',
                                    style: GoogleFonts.notoKufiArabic(
                                      fontSize: 30,
                                      color: Color(beige),
                                      fontWeight: FontWeight.bold,
                                      height: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundImage:
                                          AssetImage('assets/LOGO.png'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.person,
                                color: Color(blue),
                                size: 32,
                              ),
                              title: Text(
                                'المعلومات الشخصية',
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 25,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePage(userId: widget.userId)),
                                );
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.folder,
                                color: Color(blue),
                                size: 32,
                              ),
                              title: Text(
                                'مجلداتي',
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 25,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                              onTap: () {
                                print(widget.userId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CreateFolder(userId: widget.userId)),
                                );
                              },
                            ),

                            ListTile(
                              leading: Icon(
                                Icons.language,
                                color: Color(blue),
                                size: 32,
                              ),
                              title: Text(
                                'اللغة',
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 25,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _showLanguageDrawer =
                                      true; // Show the language drawer
                                });
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.logout,
                                color: Color(blue),
                                size: 32,
                              ),
                              title: Text(
                                'تسجيل الخروج',
                                style: GoogleFonts.notoKufiArabic(
                                  fontSize: 25,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                              onTap: () {
                                logOut();
                              },
                            ),
                          ],
                        ),
                ),
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/LOGO.png'),
                        ),
                        Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            padding: EdgeInsets.symmetric(horizontal: 30.0),
                            child: SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: Text('ماذا تريد أن تفعل؟',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.notoKufiArabic(
                                      fontSize: 32,
                                      color: Color(blue),
                                      fontWeight: FontWeight.bold,
                                      height: 1.5,
                                    )))),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: SizedBox(
                            height: 65,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CreateFolder(userId: widget.userId)),
                                );
                              },
                              icon: Icon(Icons.create_new_folder,
                                  color: Color(blue), size: 32),
                              label: Text('إنشاء مجلد'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(beige),
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 32),
                                textStyle: TextStyle(
                                    fontSize: 28,
                                    color: Color(blue),
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                                foregroundColor: Color(blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    color: Color(blue),
                                    width: 3.0,
                                  ),
                                ),
                                shadowColor: Color(blue),
                                elevation: (5.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: SizedBox(
                            height: 65,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TextToSpeech_ar(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.content_paste,
                                  color: Color(blue), size: 32),
                              label: Text('لصق نص'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(beige),
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 32),
                                textStyle: TextStyle(
                                  fontSize: 28,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                                foregroundColor: Color(blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    color: Color(blue),
                                    width: 3.0,
                                  ),
                                ),
                                shadowColor: Color(blue),
                                elevation: (5.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: SizedBox(
                            height: 65,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _initializeCamera();
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ScannerPage()),
                                );

                                if (result != null) {
                                  // TODO: Do something with the scanned image
                                }
                              },
                              icon: Icon(Icons.document_scanner,
                                  color: Color(blue), size: 32),
                              label: Text(' مسح الصفحات'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(beige),
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 32),
                                textStyle: TextStyle(
                                  fontSize: 28,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                                foregroundColor: Color(blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    color: Color(blue),
                                    width: 3.0,
                                  ),
                                ),
                                shadowColor: Color(blue),
                                elevation: (5.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: SizedBox(
                            height: 65,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => photoUpload_ar()),
                                );
                              },
                              icon: Icon(Icons.photo_camera,
                                  color: Color(blue), size: 32),
                              label: Text('تحميل صورة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(beige),
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 32),
                                textStyle: TextStyle(
                                  fontSize: 28,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                                foregroundColor: Color(blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    color: Color(blue),
                                    width: 3.0,
                                  ),
                                ),
                                shadowColor: Color(blue),
                                elevation: (5.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: SizedBox(
                            height: 65,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UploadAudioPage_ar()),
                                );
                              },
                              icon: Icon(Icons.audio_file,
                                  color: Color(blue), size: 32),
                              label: Text('الصوت الى نص'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(beige),
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 32),
                                textStyle: TextStyle(
                                  fontSize: 28,
                                  color: Color(blue),
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                                foregroundColor: Color(blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    color: Color(blue),
                                    width: 3.0,
                                  ),
                                ),
                                shadowColor: Color(blue),
                                elevation: (5.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))));
  }

  void logOut() {
    // Clear the user session or perform any other necessary actions
    // For example, you can clear user-related data from shared preferences or local storage

    // Navigate to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LogoPage()),
      (Route<dynamic> route) => false,
    );
  }
}
