import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? userEmail;
  String? userPhoto;
  String? userBio;
  String? memberSince;
  String? currentPassword;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var response = await http.post(
      Uri.parse('http://192.168.100.10/TTS/getUserData.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': widget.userId,
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          userName = responseData['user_name'];
          userEmail = responseData['user_email'];
          String userPhotoPath = responseData['user_photo'] ?? '';
          if (userPhotoPath.isNotEmpty) {
            userPhoto = 'http://192.168.100.10/TTS/uploads/$userPhotoPath';
          } else {
            userPhoto = 'http://192.168.100.10/TTS/uploads/UserIcon.jpeg';
          }
          userBio = responseData['user_bio'];
          memberSince = responseData['member_since'];
          currentPassword = responseData['user_password'];
        });
      } else {
        print('Failed to fetch user data: ${responseData['message']}');
      }
    } else {
      print('Failed to connect to server');
    }
  }

  Widget _bioInputField() {
    return TextField(
      maxLength: 50, // Set the maximum length to 50 characters
      onChanged: (value) {
        setState(() {
          userBio = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'أدخل النص',
      ),
    );
  }

  Widget _bioSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => updateBio(widget.userId, userBio!, context),
      // Pass the context
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Color(blue)),
      ),
      child: Text(
        'تأكيد الوصف الجديد',
        style: GoogleFonts.notoKufiArabic(
          color: Color(beige),
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _userPhoto() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: userPhoto != null && userPhoto!.isNotEmpty
              ? NetworkImage(userPhoto!) as ImageProvider<Object>?
              : null, // Use null to indicate no image
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              _uploadPhotoFromDevice();
            },
          ),
        ),
      ],
    );
  }

  Future<void> _uploadPhotoFromDevice() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      if (base64Image.isNotEmpty) {
        try {
          // Add a delay of 1 second before updating the photo
          await Future.delayed(Duration(seconds: 1));
          // Call the method to update the photo in the database
          final photoUrl = await updatePhoto(widget.userId, base64Image);
          // Once uploaded successfully, update the local state as well
          setState(() {
            userPhoto = photoUrl;
          });
        } catch (e) {
          print('Failed to upload photo: $e');
        }
      } else {
        print('Base64 image is empty');
      }
    } else {
      print('No image was picked.');
    }
  }

  Widget _passwordUpdateDialog(BuildContext context) {
    String newPassword = '';
    String confirmPassword = '';
    return Dialog(
      backgroundColor: Color(beige),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تعديل كلمة السر',
              style: GoogleFonts.notoKufiArabic(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Color(blue),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            TextField(
              obscureText: true,
              onChanged: (value) {
                newPassword = value;
              },
              decoration: InputDecoration(
                hintText: 'كلمة السر الجديدة',
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              obscureText: true,
              onChanged: (value) {
                confirmPassword = value;
              },
              decoration: InputDecoration(
                hintText: 'تأكيد كلمة السر',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => updatePassword(
                widget.userId,
                newPassword,
                confirmPassword,
                context,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(blue)),
              ),
              child: Text(
                'تأكيد',
                style: GoogleFonts.notoKufiArabic(
                  color: Color(beige),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updatePassword(String userId, String newPassword,
      String confirmPassword, BuildContext context) async {
    // Check if the two passwords match
    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(beige),
          title: Text(
            'خطأ',
            style: GoogleFonts.notoKufiArabic(
              fontSize: 38.0,
              fontWeight: FontWeight.bold,
              color: Color(blue),
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'تأكد من تطابق كلمة السر',
            style: GoogleFonts.notoKufiArabic(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Color(blue),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the error dialog
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(blue)),
              ),
              child: Text(
                'تأكيد',
                style: GoogleFonts.notoKufiArabic(
                  color: Color(beige),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    var response = await http.post(
      Uri.parse('http://192.168.100.10/TTS/updateUserData.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': userId,
        'new_password': newPassword,
        'confirm_new_password': confirmPassword, // Add this line
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        Navigator.pop(context); // Close the dialog after successful update
      } else {
        print('Failed to update password: ${responseData['message']}');
      }
    } else {
      print('Failed to connect to server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(beige),
        fontFamily: GoogleFonts.notoKufiArabic().fontFamily,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50.0),
                Text(
                  'المعلومات الشخصية', // Add the title
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 24,
                    color: Color(blue),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                _userPhoto(), // Display the user's photo
                SizedBox(height: 20.0),
                _customListTile(
                  title: 'اسم المستخدم',
                  subtitle: userName ?? '',
                ),
                SizedBox(height: 20.0),
                _customListTile(
                  title: 'البريد الالكتروني',
                  subtitle: userEmail ?? '',
                ),
                SizedBox(height: 20.0),
                _customListTile(
                  title: 'كلمة السر',
                  subtitle: '********', // Masked for security
                  onEditPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => _passwordUpdateDialog(context),
                    );
                  },
                  isPasswordField: true, // Add this line
                ),
                SizedBox(height: 20.0),
                _customListTile(
                  title: 'عضو منذ',
                  subtitle: memberSince ?? '',
                ),
                SizedBox(height: 20.0),
                _customListTile(
                  title: 'وصف',
                  subtitle: userBio ?? '',
                  onEditPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Color(beige),
                        title: Text('تعديل الوصف',
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Color(blue),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: _bioInputField(),
                        actions: [
                          _bioSubmitButton(context),
                        ],
                      ),
                    );
                  },
                  isBioField: true, // Specify that this is the bio field
                ),
                SizedBox(height: 50.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateBio(
      String userId, String userBio, BuildContext context) async {
    if (userBio.length > 50) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(beige),
          title: Text('خطأ!',
            style: GoogleFonts.notoKufiArabic(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Color(blue),
            ),
            textAlign: TextAlign.center,
          ),
          content: Text('الوصف يجب أن لا يتجاوز 50 رمز',
            style: GoogleFonts.notoKufiArabic(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Color(blue),
            ),),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the error dialog
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(blue)),
              ),
              child: Text(
                'تأكيد',
                style: GoogleFonts.notoKufiArabic(
                  color: Color(beige),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    var response = await http.post(
      Uri.parse('http://192.168.100.10/TTS/updateUserData.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': userId,
        'user_bio': userBio,
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          this.userBio = userBio; // Update the userBio value in the state
        });
        Navigator.pop(context); // Close the dialog after successful update
      } else {
        print('Failed to update bio: ${responseData['message']}');
      }
    } else {
      print('Failed to connect to server');
    }
  }

  Future<String> updatePhoto(String userId, String? base64Image) async {
    var response = await http.post(
      Uri.parse('http://192.168.100.10/TTS/updateUserData.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': userId,
        'user_photo': base64Image ?? '',
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        return 'http://192.168.100.10/TTS/uploads/' +
            responseData['photo_name'];
      } else {
        print('Failed to update photo: ${responseData['message']}');
        return 'DefaultImageUrl'; // return a default image url here
      }
    } else {
      print('Failed to connect to server');
      return 'DefaultImageUrl'; // return a default image url here
    }
  }

  Widget _customListTile({
    required String title,
    required String subtitle,
    Function? onEditPressed,
    bool isBioField = false,
    bool isPasswordField = false, // Add this line
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoKufiArabic(
            fontSize: 20,
            color: Color(blue),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Center(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
        trailing: isBioField || isPasswordField // Update this line
            ? IconButton(
                icon: Icon(Icons.edit),
                onPressed: onEditPressed as void Function()?,
              )
            : null, // Hide the edit icon for non-bio fields and non-password fields
      ),
    );
  }
}
