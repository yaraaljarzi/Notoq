import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutterproject/inputmethods_ar.dart';
import 'package:flutterproject/login_en.dart';
import 'package:flutterproject/profile_en.dart';
import 'package:flutterproject/speech_to_text.dart';
import 'ScannerPage_en.dart';
import 'create_folder.dart';
import 'dart:io';
import 'paste_text_en.dart';
import 'photo_upload.dart';
import 'mainpage_en.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;
late CameraController _camera;

//void main() => runApp(inputmethods(userId: userId,));

class inputmethods extends StatefulWidget {
  final String userId;

  inputmethods({required this.userId});

  @override
  _inputmethodsState createState() => _inputmethodsState();
}

class _inputmethodsState extends State<inputmethods> {
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

  void logout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogoPage_en(),
      ),
    );
    print('Logout button pressed');
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
              key: _scaffoldKey1,
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
                      _scaffoldKey1.currentState?.openEndDrawer();
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
                              'Choose Language',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(beige),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'English',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(blue),
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
                          ListTile(
                            title: Text(
                              'Arabic',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(blue),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        inputmethods_ar(userId: widget.userId)),
                              );
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
                                  'Settings',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(beige),
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
                              'Personal Info',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(blue),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePageE(userId: widget.userId)),
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
                              'My Folders',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(blue),
                              ),
                            ),
                            onTap: () {
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
                              'Language',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(blue),
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
                              'Log Out',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(blue),
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
                              height: 75,
                              width: double.infinity,
                              child: Text(
                                'What do you want to do?',
                                style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(blue),
                                    height: 1),
                              ))),
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
                            label: Text('Create Folder'),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TextToSpeech_en()),
                              );
                            },
                            icon: Icon(Icons.content_paste,
                                color: Color(blue), size: 32),
                            label: Text('Paste Text'),
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
                            onPressed: () async {
                              await _initializeCamera();
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ScannerPage_en()),
                              );
                              if (result != null) {
                                // TODO: Do something with the scanned image
                              }
                            },
                            icon: Icon(Icons.document_scanner,
                                color: Color(blue), size: 32),
                            label: Text('Scan Pages'),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => photoUpload()),
                              );
                            },
                            icon: Icon(Icons.photo_camera,
                                color: Color(blue), size: 32),
                            label: Text('Upload Photo'),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UploadAudioPage()),
                              );
                            },
                            icon: Icon(Icons.audio_file,
                                color: Color(blue), size: 32),
                            label: Text('Speech To Text'),
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
                    ],
                  ),
                ),
              )),
        ));
  }

  void logOut() {
    // Clear the user session or perform any other necessary actions
    // For example, you can clear user-related data from shared preferences or local storage

    // Navigate to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LogoPage_en()),
      (Route<dynamic> route) => false,
    );
  }
}
