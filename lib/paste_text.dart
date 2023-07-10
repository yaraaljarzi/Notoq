import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'audioplayerpage_ar.dart';
import 'package:google_fonts/google_fonts.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

void main() {
  runApp(MaterialApp(
    home: TextToSpeech_ar(),
    theme: ThemeData(
      scaffoldBackgroundColor: Color(beige),
    ),
  ));
}

class TextToSpeech_ar extends StatefulWidget {
  @override
  _TextToSpeechState createState() => _TextToSpeechState();
}

class _TextToSpeechState extends State<TextToSpeech_ar> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isLoading = false;
  String _audioUrl = '';
  String _selectedGender = 'ذكر'; // Default selection
  final List<String> _genderOptions = ['ذكر', 'انثى'];

  void _convertToAudio() async {
    setState(() {
      _isLoading = true;
      _audioUrl = '';
    });

    String backendUrl;
    if (_selectedGender == 'ذكر') {
      backendUrl = 'http://192.168.100.10/TTS/PasteTextMale.php';
    } else {
      backendUrl = 'http://192.168.100.10/TTS/PasteTextFemale.php';
    }

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
    };
    final body = {'text': _textEditingController.text, 'language': 'ar'};

    try {
      final response =
          await http.post(Uri.parse(backendUrl), headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _audioUrl = jsonResponse['mp3Url'];
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _downloadAudio() async {
    final dir = await getExternalStorageDirectory();
    final file = File('${dir?.path}/audio.mp3');
    await _downloadFromCloudStorage(_audioUrl, file);
    print('File saved to: ${file.path}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File saved to: ${file.path} '),
      ),
    );
  }

  void _navigateToAudioPlayerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerPage_ar(audioUrl: _audioUrl),
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
        //title: Text('Text To Speech'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Text(
                      'تحويل النص الى صوت',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 30,
                        color: Color(blue),
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  )),
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'ادخل النص باللغة العربية هنا...',
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
              ),
              SizedBox(height: 20.0),
              Text(
                'جنس القارىء',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(blue)),
              ),
              SizedBox(height: 20.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  hintText: 'اختر الجنس',
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
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _convertToAudio,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        'تحويل الى صوت',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 30,
                          color: Color(blue),
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(beige),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
              SizedBox(height: 20.0),
              if (_audioUrl.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text('Audio file URL:'),
                    //SelectableText(_audioUrl),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _downloadAudio,
                      child: Text(
                        ' تحميل',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 30,
                          color: Color(blue),
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(beige),
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _navigateToAudioPlayerPage,
                      child: Text(
                        'استماع',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoKufiArabic(
                          fontSize: 30,
                          color: Color(blue),
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(beige),
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
