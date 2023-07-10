import 'dart:convert';
import 'dart:io';
import 'audioplayerpage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

void main() {
  runApp(photoUpload());
}

class photoUpload extends StatelessWidget {
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
        body: SingleChildScrollView(child: ImageUpload()),
      ),
    );
  }
}

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? _image;
  String? _audioUrl;
  bool _isUploading = false;
  String _selectedGender = 'Male'; // Default selection
  final List<String> _genderOptions = ['Male', 'Female'];

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true; // Set the flag to true before uploading
    });

    String backendUrl;
    if (_selectedGender == 'Male') {
      backendUrl = 'http://192.168.100.10/TTS/ImageMale.php';
    } else {
      backendUrl = 'http://192.168.100.10/TTS/ImageFemale.php';
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(backendUrl),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: basename(imageFile.path),
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      // Read the response from the backend
      final responseBody = await response.stream.bytesToString();
      print('Backend response: $responseBody');

      // Parse the JSON response
      final jsonResponse = jsonDecode(responseBody);
      setState(() {
        _audioUrl = jsonResponse['audioUrl'];
        _isUploading = false; // Set the flag to false after uploading
      });
    } else {
      print('Image upload failed');
      setState(() {
        _isUploading = false; // Set the flag to false if upload fails
      });
    }
  }


  void _navigateToAudioPlayerPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerPage(audioUrl: _audioUrl!),
      ),
    );
  }

  void _downloadAudio(BuildContext context) async {
    final dir = await getExternalStorageDirectory();
    final file = File('${dir?.path}/audio.mp3');
    await _downloadFromCloudStorage(_audioUrl!, file);
    print('File saved to: ${file.path}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File saved to: ${file.path} '),
      ),
    );
  }

  Future<void> _downloadFromCloudStorage(String url, File file) async {
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: Text(
                    'Image upload',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(blue)),
                  ))),
          if (_image != null)
            Image.file(
              _image!,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(beige),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              textStyle: TextStyle(
                fontSize: 28,
                color: Color(blue),
                fontWeight: FontWeight.bold,
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
          // gender
          SizedBox(height: 20.0),
          Text(
            'Gender of reader',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(blue)),
          ),
          SizedBox(height: 20.0),
          DropdownButtonFormField(
            decoration: InputDecoration(
              hintText: 'Select a gender',
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
            ),
            value: _selectedGender,
            onChanged: (newValue) {
              setState(() {
                _selectedGender = newValue!;
              });
            },
            items: _genderOptions.map((gender) {
              return DropdownMenuItem(
                child: Text(gender),
                value: gender,
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          if (_image != null)
            ElevatedButton(
              onPressed: _isUploading ? null : () => _uploadImage(_image!),
              child: _isUploading
                  ? CircularProgressIndicator() // Show loading indicator if uploading
                  //() => _uploadImage(_image!),
                  : Text('Upload Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(beige),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: TextStyle(
                  fontSize: 28,
                  color: Color(blue),
                  fontWeight: FontWeight.bold,
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
          SizedBox(height: 20),
          if (_audioUrl != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _downloadAudio(context),
                  child: Text('Download Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(beige),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle: TextStyle(
                      fontSize: 28,
                      color: Color(blue),
                      fontWeight: FontWeight.bold,
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _navigateToAudioPlayerPage(context),
                  child: Text('Play Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(beige),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle: TextStyle(
                      fontSize: 28,
                      color: Color(blue),
                      fontWeight: FontWeight.bold,
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
              ],
            )
        ],
      ),
    );
  }
}
