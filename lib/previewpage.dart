import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutterproject/audioplayerpage.dart';

final int blue = 0xFF090088;
final int beige = 0xFFF1F7B5;

class PreviewPage_en extends StatefulWidget {
  final Uint8List image;

  PreviewPage_en({required this.image});

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage_en> {
  bool _isUploading = false;
  String? _audioUrl;
  String _selectedGender = 'Male'; // Default selection
  final List<String> _genderOptions = ['Male', 'Female'];

  Future<File> _getImageFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = await new File('${tempDir.path}/image.png').create();
    await file.writeAsBytes(widget.image);
    return file;
  }

  Future<void> _uploadImage(Uint8List imageBytes) async {
    setState(() {
      _isUploading = true;
    });

    final imageFile = await _getImageFile();

    String backendUrl;
    if (_selectedGender == 'Male') {
      backendUrl = 'http://192.168.100.10/TTS/ImageMale.php';
    } else {
      backendUrl = 'http://192.168.100.10/TTS/ImageFemale.php';
    }

    // Attach the image file to the request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(backendUrl),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: basename(imageFile.path),
    ));

    // Send the request
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

  Future<void> _downloadAudio(BuildContext context) async {
    if (_audioUrl == null) {
      return;
    }
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
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Preview',
            style: TextStyle(
              color: Color(blue),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          child: Stack(
            children: [
              Center(child: Image.memory(widget.image)),
              Positioned(
                bottom: 16.0,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      ElevatedButton.icon(
                        onPressed: _isUploading
                            ? null
                            : () async {
                                await _uploadImage(widget.image);
                              },
                        icon: SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.cloud_upload,
                            color: Color(beige),
                            size: 32,
                          ),
                        ),
                        label: _isUploading
                            ? Text('Uploading...',
                                style: TextStyle(
                                  color: Color(beige),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ))
                            : Text('Upload Image',
                                style: TextStyle(
                                  color: Color(beige),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                )),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Color(blue);
                              }
                              return Color(blue);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Gender of reader',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(blue)),
                      ),
                      //SizedBox(height: 20.0),
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
                      if (_audioUrl != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _downloadAudio(context),
                              icon: SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.file_download,
                                  color: Color(beige),
                                  size: 32,
                                ),
                              ),
                              label: Text('Download',
                                  style: TextStyle(
                                    color: Color(beige),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  )),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Color(blue);
                                    }
                                    return Color(blue);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _navigateToAudioPlayerPage(context),
                              icon: SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Color(beige),
                                  size: 32,
                                ),
                              ),
                              label: Text('Play',
                                  style: TextStyle(
                                    color: Color(beige),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  )),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Color(blue);
                                    }
                                    return Color(blue);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
