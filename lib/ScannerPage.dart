import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'previewpage_ar.dart';

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isCameraInitializing = true;
  late CameraController cameraController;
  XFile? _capturedImage;
  final int blue = 0xFF090088;
  final int beige = 0xFFF1F7B5;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cameraController.initialize();
    if (mounted) {
      setState(() {
        _isCameraInitializing = false;
      });
    }
  }

  bool _checkCameraDisposed() {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return true;
    }
    return false;
  }

  Future<CameraController> _createCameraController() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    return CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
  }

  Future<void> _restartCameraPreview() async {
    try {
      await cameraController.dispose();
      cameraController = await _createCameraController();
      await cameraController.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error restarting camera preview: $e");
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Color(beige),
        appBar: AppBar(
          title: Text(
            'مسح الصفحات',
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
          child: _capturedImage == null
              ? _buildCameraPreview()
              : _buildImagePreview(),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isCameraInitializing) {
      return Center(child: CircularProgressIndicator());
    }
    if (_checkCameraDisposed()) {
      return Center(child: CircularProgressIndicator());
    }
    return Visibility(
      visible: _capturedImage == null,
      child: Container(
        child: Stack(
          children: [
            CameraPreview(cameraController),
            Positioned(
              bottom: 16.0,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_checkCameraDisposed()) {
                      return;
                    }
                    try {
                      XFile image = await cameraController.takePicture();
                      setState(() {
                        _capturedImage = image;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  icon: Icon(Icons.camera_alt, color: Color(beige), size: 32),
                  label: Text(
                    'التقط الصورة',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 28,
                      color: Color(beige),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _readImageBytes() async {
    try {
      if (kIsWeb) {
// Read image bytes from the web environment
        return await _capturedImage!.readAsBytes();
      } else {
// Read image bytes in a non-web environment
        return await File(_capturedImage!.path).readAsBytes();
      }
    } catch (e) {
      print('Error reading image bytes: $e');
      return Uint8List(0); // Return an empty
    }
  }

  Widget _buildImagePreview() {
    return FutureBuilder(
        future: _readImageBytes(),
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.memory(snapshot.data!),
                SizedBox(height: 20),
// added a SizedBox to add some space between the image and the buttons
                Visibility(
                  visible: _capturedImage != null,
                  child: Column(
// wrapped ElevatedButtons inside a Column to stack them vertically
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _capturedImage = null;
                          });
                          await _restartCameraPreview();
                        },
                        child: Text(
                          'التقط مجددًا',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 28,
                            color: Color(beige),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                      ),
                      SizedBox(height: 10),
// added a SizedBox to add some space between the buttons
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PreviewPage_ar(image: snapshot.data!),
                            ),
                          );
                        },
                        child: Text(
                          'إقرأ الصورة',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 28,
                            color: Color(beige),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: Text('Error: Unable to display image'));
          }
        });
  }
}
