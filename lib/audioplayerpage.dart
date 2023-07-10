import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

class AudioPlayerPage extends StatefulWidget {
  final String audioUrl;

  AudioPlayerPage({required this.audioUrl});

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _duration = duration!;
        });
      });
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.playing != _isPlaying) {
          setState(() {
            _isPlaying = playerState.playing;
          });
        }
      });
    } catch (e) {

    }
  }

  void _togglePlaying() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  String formatDuration(Duration duration) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          'Audio Player',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Color(blue)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isPlaying ? 'Playing' : 'Paused',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Slider(
              value: _position.inSeconds.toDouble(),
              min: 0.0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(_position),
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  formatDuration(_duration),
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10),
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      _audioPlayer.seek(_position - Duration(seconds: 10));
                    });
                  },
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 64,
                  onPressed: _togglePlaying,
                ),
                IconButton(
                  icon: Icon(Icons.forward_10),
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      _audioPlayer.seek(_position + Duration(seconds: 10));
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Playback Speed:',
                  style: TextStyle(fontSize: 18),
                ),
                DropdownButton<double>(
                  value: _playbackSpeed,
                  onChanged: (value) {
                    setState(() {
                      _playbackSpeed = value!;
                      _audioPlayer.setSpeed(_playbackSpeed);
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 0.5,
                      child: Text('0.5x'),
                    ),
                    DropdownMenuItem(
                      value: 0.75,
                      child: Text('0.75x'),
                    ),
                    DropdownMenuItem(
                      value: 1.0,
                      child: Text('1.0x'),
                    ),
                    DropdownMenuItem(
                      value: 1.25,
                      child: Text('1.25x'),
                    ),
                    DropdownMenuItem(
                      value: 1.5,
                      child: Text('1.5x'),
                    ),
                    DropdownMenuItem(
                      value: 2.0,
                      child: Text('2.0x'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
