import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'inside_folders.dart';
import 'inputmethods.dart';

const int blue = 0xFF090088;
const int beige = 0xFFF1F7B5;

class CreateFolder extends StatelessWidget {
  final String userId;

  const CreateFolder({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(beige),
      ),
      home: FolderListPage(userId: userId),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Folder {
  final dynamic id;
  final String userId;
  final String name;
  final String dateCreated;

  Folder({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateCreated,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['folder_id'],
      userId: json['user_id'] != null ? json['user_id'].toString() : '',
      name: json['folder_name'] != null ? json['folder_name'] : '',
      dateCreated: json['date_created'] != null ? json['date_created'] : '',
    );
  }
}

class FolderListPage extends StatefulWidget {
  final String userId;

  FolderListPage({required this.userId});

  @override
  _FolderListPageState createState() => _FolderListPageState();
}

class _FolderListPageState extends State<FolderListPage> {
  List<Folder> folders = [];
  int _selectedFolderIndex = -1;

  @override
  void initState() {
    super.initState();
    fetchFolders();
  }

  Future<void> fetchFolders() async {
    var url = 'http://192.168.100.10/TTS/fetch_folders.php';
    var response = await http.post(Uri.parse(url), body: {
      'user_id': widget.userId,
    });

    if (response.statusCode == 200) {
      //print('Response Body: ${response.body}');
      var data = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        folders =
            data.map((folderData) => Folder.fromJson(folderData)).toList();
      });
    } else {
      print('Failed to fetch folders.');
    }
  }

  Future<void> createFolder(String folderName) async {
    if (folderName.isNotEmpty) {
      var url = 'http://192.168.100.10/TTS/create_folder.php';
      var response = await http.post(Uri.parse(url), body: {
        'user_id': int.parse(widget.userId).toString(),
        'folder_name': folderName,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          var newFolder = Folder.fromJson(data['folder']);
          setState(() {
            folders.add(newFolder);
          });
        } else {
          print('Error creating folder: ' + data['message']);
        }
      } else {
        print('Error creating folder: ' +
            (response.reasonPhrase ?? 'Unknown error'));
      }
    } else {
      print('Error creating folder: Please provide a folder name');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('User ID: ${widget.userId}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(blue),
          iconSize: 32,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => inputmethods(
                    userId: widget.userId),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Folders',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(blue)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFolderIndex = index;
                        });
                        print('Folder ID: ${folders[index].id}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InsideFolderPage(
                              folder: folders[index],
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(
                              3, 2, 0.001) // Add a small perspective effect
                          ..rotateX(_selectedFolderIndex == index ? -0.1 : 0),
                        // Rotate the folder when selected
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(beige),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: _selectedFolderIndex == index
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 2.0,
                            ),
                            boxShadow: _selectedFolderIndex == index
                                ? [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 8.0,
                                      spreadRadius: 2.0,
                                    ),
                                  ]
                                : [], // Apply shadow only when selected
                          ),
                          child: ListTile(
                            title: Text(
                              folders[index].name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Color(blue)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      color: Color(blue).withOpacity(0.5),
                      thickness: 1.0,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CreateFolderDialog(
                onCreateFolder: createFolder,
              );
            },
          );
        },
        child: Icon(
          Icons.create_new_folder,
          size: 45,
          color: Color(beige),
        ),
        backgroundColor: Color(blue),
        foregroundColor: Color(beige),
      ),
    );
  }
}

class CreateFolderDialog extends StatefulWidget {
  final Function(String) onCreateFolder;

  CreateFolderDialog({required this.onCreateFolder});

  @override
  _CreateFolderDialogState createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController _folderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(beige),
      title: Text(
        'Create New Folder',
        style: TextStyle(color: Color(blue), fontSize: 28),
      ),
      content: TextField(
        controller: _folderNameController,
        decoration: InputDecoration(
          hintText: 'Folder Name',
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(beige),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            textStyle: TextStyle(
              fontSize: 26,
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
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Color(blue),
              // fontSize: 20,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String folderName = _folderNameController.text;
            widget.onCreateFolder(folderName);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(beige),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            textStyle: TextStyle(
              fontSize: 26,
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
          child: Text(
            'Create',
            style: TextStyle(
              color: Color(blue),
              // fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
