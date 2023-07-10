import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'inputmethods_ar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

class SpeechPage extends StatelessWidget {
  final String userId;

  const SpeechPage({Key? key, required this.userId}) : super(key: key);

  final String text =
      "مرحبًا بكم في نُطق، الذي تم تصميمه خصيصًا لذوي الإعاقة البصرية. يقوم تطبيقنا بتحويل النصوص إلى نطق، مما يتيح للمستخدمين الوصول بسلاسة وسهولة إلى المعلومات المكتوبة. يمكن للمستخدم سماع أي نص مكتوب صوتيًا، مما يتيح التفاعل مع الأخبار الأخيرة والتواصل مع العائلة والأصدقاء والوصول إلى مجموعة واسعة من المحتويات المكتوبة الأخرى. نأمل أن يكون تطبيقنا قادرًا على صناعة فرق معنويّ في حياة ذوي الإحتياجات الخاصّة ، ونتعهد بمواصلة تحسين وتحديث التطبيق لتلبية احتياجاتهم. شكرًا لاختياركم تطبيقنا.";

  @override
  Widget build(BuildContext context) {
    print('User ID: ${this.userId}'); // Print the value of userId
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(beige),
        textTheme: GoogleFonts.notoKufiArabicTextTheme(),
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
                    double screenWidth = constraints.maxWidth;
                    double fontSizeFactor = screenWidth < 800 ? 0.04 : 0.025;
                    return Text(
                      text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoKufiArabic(
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
                          builder: (context) => inputmethods_ar(
                            userId: userId,
                          ),
                        ),
                      );
                    },
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Text(
                          'استمرار',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoKufiArabic(
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
    final audioPlayer = AudioPlayer();
    await audioPlayer.stop(); // Stop any previously playing audio
    await audioPlayer.setAsset('assets/Arabic.mp3');
    await audioPlayer.play();
    audioPlayer.dispose();
  }
}
