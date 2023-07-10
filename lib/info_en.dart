import 'package:flutter/material.dart';
import 'inputmethods.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

void main() {
  runApp(SpeechPage_en(userId: '123')); // Replace '123' with the actual user ID
}

class SpeechPage_en extends StatefulWidget {
  final String userId;

  SpeechPage_en({Key? key, required this.userId}) : super(key: key);

  @override
  _SpeechPage_enState createState() => _SpeechPage_enState();
}

class _SpeechPage_enState extends State<SpeechPage_en> {
  late AudioPlayer audioPlayer;
  final String audioFilePath = 'assets/English.mp3';

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  final String text =
      "Welcome to Notoq, designed specifically for vision impaired users. Our app converts texts to speech, allowing users to easily and effortlessly access written information. User can hear any text read aloud to them, making it easy to stay up-to-date with the latest news, connect with friends and family, and access a wide range of other written content. We hope our app will make a meaningful difference in the lives of vision impaired users, and we are committed to continually improving and updating it to meet their needs. Thank you for choosing our app.";

  @override
  Widget build(BuildContext context) {
    print('User ID: ${widget.userId}'); // Print the value of userId
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(beige),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(beige),
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
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(beige),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(blue),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.0),
                Container(
                  width: 200,
                  height: 70,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => inputmethods(
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Text(
                          'Continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(beige),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  height: 70,
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      playAudio();
                    },
                    backgroundColor: Color(blue),
                    child: Icon(
                      Icons.play_arrow,
                      color: Color(beige),
                      size: 60,
                    ),
                    foregroundColor: Color(beige),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void playAudio() async {
    await audioPlayer.stop(); // Stop any previously playing audio
    await audioPlayer.setAsset(audioFilePath);
    await audioPlayer.play();
  }

  @override
  void dispose() {
    audioPlayer.dispose(); // Release resources upon widget disposal
    super.dispose();
  }
}
