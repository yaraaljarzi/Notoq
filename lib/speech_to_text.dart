import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(UploadAudioPage());
}

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

class UploadAudioPage extends StatefulWidget {
  @override
  _UploadAudioPageState createState() => _UploadAudioPageState();
}

class _UploadAudioPageState extends State<UploadAudioPage> {
  File? _audioFile;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String>? _transcripts;
  bool _isLoading = false;

  Future<void> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
    );

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadAudio() async {
    if (_audioFile == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.100.10/TTS/SpeechToText.php'),
    );
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      _audioFile!.path,
    ));
    var res = await request.send();
    if (res.statusCode == 200) {
      print("Uploaded!");

      // Read the response
      res.stream.bytesToString().then((value) {
        try {
          setState(() {
            _transcripts = List<String>.from(jsonDecode(value));
          });
          print(_transcripts);
        } catch (e) {
          print('Error decoding JSON: $e');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      print("Upload failed.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> playAudio() async {
    if (_audioFile != null) {
      await _audioPlayer.setFilePath(_audioFile!.path);
      _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: Text(
                      'Speech-To-Text',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(blue),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: SizedBox(
                    height: 185,
                    width: double.infinity,
                    child: Text(
                      'extracting the transcript of an Arabic audio file, only .wav audio is supported',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(blue),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Text('Pick Audio'),
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
                    elevation: 5.0,
                  ),
                  onPressed: pickAudio,
                ),
                SizedBox(height: 20.0),
                if (_audioFile != null) ...[
                  Text(
                    'Selected File: ${_audioFile!.path.split('/').last}',
                    style: TextStyle(
                      color: Color(blue),
                      fontSize: 23,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text('Upload Audio'),
                        if (_isLoading)
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Color(blue)),
                          ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(beige),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
                      elevation: 5.0,
                    ),
                    onPressed: _isLoading ? null : uploadAudio,
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    child: Text('Play Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(beige),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
                      elevation: 5.0,
                    ),
                    onPressed: playAudio,
                  ),
                  SizedBox(height: 20.0),
                  if (_transcripts != null) ...[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color(beige),
                        border: Border.all(
                          color: Color(blue),
                          width: 3.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transcripts:',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(blue),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          ..._transcripts!
                              .map(
                                (transcript) => Text(
                                  transcript,
                                  style: TextStyle(
                                    color: Color(blue),
                                    fontSize: 20,
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
