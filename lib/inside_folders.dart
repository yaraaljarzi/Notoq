import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'create_folder.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class InsideFolderPage extends StatefulWidget {
  final Folder folder;
  final String userId;

  InsideFolderPage({required this.folder, required this.userId});

  @override
  _InsideFolderPageState createState() => _InsideFolderPageState();
}

class _InsideFolderPageState extends State<InsideFolderPage> {
  List<FileData> files = [];

  @override
  void initState() {
    super.initState();
    print('Folder ID: ${widget.folder.id}');
    print('User ID: ${widget.userId}');
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    var url = 'http://192.168.100.10/TTS/insidefolders_fetch.php';
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'folder_id': widget.folder.id.toString(),
      },
    );
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        var filesData = data['files'] as List<dynamic>;
        setState(() {
          files =
              filesData.map((fileData) => FileData.fromJson(fileData)).toList();
        });
      } else {
        print('Failed to fetch files: ${data['message']}');
      }
    } else {
      print('Failed to fetch files. Status code: ${response.statusCode}');
    }
  }

  Future<void> uploadImage() async {
    var imagePicker = ImagePicker();
    var pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      var imageFile = File(pickedImage.path);

      var url = 'http://192.168.100.10/TTS/insidefolders_upload.php';
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['folder_id'] = widget.folder.id.toString();
      request.fields['user_id'] = widget.userId;
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var data = jsonDecode(responseString);
        if (data['status'] == 'success') {
          var newFile = FileData.fromJson(data['file']);
          setState(() {
            files.add(newFile);
          });
          fetchFiles(); // Call fetchFiles to update the file list
        } else {
          print('Error uploading image: ${data['message']}');
        }
      } else {
        print('Error uploading image: ${response.reasonPhrase}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folder.name,
          style: TextStyle(
            color: Color(blue),
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(blue),
          iconSize: 32,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: index == 0
                    ? BorderSide.none
                    : BorderSide(
                        color: Color(blue),
                        width: 1.0,
                      ),
                bottom: BorderSide(
                  color: Color(blue),
                  width: 1.0,
                ),
              ),
            ),
            child: ListTile(
              key: ValueKey(files[index].fileId), // Assign a unique key
              title: Text(
                files[index].name,
                style: TextStyle(
                  //fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(blue),
                ),
              ),
              onTap: () {
                // Open the image when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ImageViewPage(imageData: files[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Call the uploadImage method when the button is pressed
          uploadImage();
        },
        child: Icon(
          Icons.upload,
          size: 45,
          color: Color(beige),
        ),
        backgroundColor: Color(blue),
        foregroundColor: Color(beige),
      ),
    );
  }
}

class ImageViewPage extends StatelessWidget {
  final FileData imageData;

  ImageViewPage({required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          imageData.name,
          style: TextStyle(
            color: Color(blue),
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(blue),
          iconSize: 32,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Image.network(imageData.url),
      ),
    );
  }
}

class FileData {
  final int fileId;
  final String name;
  final String url;

  FileData({
    required this.fileId,
    required this.name,
    required this.url,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      fileId: json['file_id'] ?? 0,
      name: json['file_name'] ?? '',
      url: json['file_url'] ?? '',
    );
  }
}
