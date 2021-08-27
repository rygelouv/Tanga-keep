import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep/model/book.dart';
import 'package:keep/model/user.dart';
import 'package:keep/service/books_service.dart';
import 'package:provider/provider.dart';

import '../styles.dart';
import 'home_screen.dart';
import 'package:path/path.dart' as Path;

class BookEditor extends StatefulWidget {
  const BookEditor({Key key, @required this.book}) : super(key: key);
  final Book book;

  @override
  _BookEditorState createState() => _BookEditorState(book);
}

class _BookEditorState extends State<BookEditor> {

  _BookEditorState(this._book);

  TextEditingController _bookTitleController;

  final Book _book;

  bool _validURL = false;

  @override
  void initState() {
    super.initState();
    _bookTitleController = TextEditingController(text: _book.title);
  }

  @override
  void dispose() {
    _bookTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<CurrentUser>(context).data.uid;
    _validURL = Uri.parse(_book.cover).isAbsolute;
    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Edit Book"),
      ),
      body: SingleChildScrollView(
      child: Center(
        child: Container(
          margin: EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
          controller: _bookTitleController,
            style: kNoteTitleLight,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              labelText: 'Book Title',
              border: OutlineInputBorder(),
              counter: const SizedBox(),
            ),
            textCapitalization: TextCapitalization.sentences,
        ),
          _book.cover == "" ? showBookCover() : const Text("No cover image for this book")
        ]
      ),
      ),
      ),
      ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    floatingActionButton: FloatingActionButton.extended(
    backgroundColor: Theme.of(context).accentColor,
    onPressed: () => _onSave(uid),
    heroTag: null,
    icon: Icon(Icons.check),
    label: Text("Save"),
    ),
    );
  }

  Future _onSave(String uid) async {
    _book.title = _bookTitleController.text;
    print("---------- $_validURL--------");
    if (_validURL != true && _book.cover != "") {
      var newFileName = _bookTitleController.text.replaceAll(
          new RegExp(r"\s+"), "").toLowerCase();
      final newFile = await changeFileNameOnly(File(_book.cover), newFileName);
      StorageUploadTask uploadTask = storageReference(newFile.path).putFile(
          newFile);
      await uploadTask.onComplete;
      print('File Uploaded');
      await storageReference(newFile.path).getDownloadURL().then((fileURL) {
        _book.cover = fileURL;
        print(fileURL);
      });
    }
    _book.addBook(uid);
    Navigator.pop(context);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  /*
  This method take the file path, retrieve
  the substring and add it to the new filename
   */
  Future<File> changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var ext = Path.extension(path);
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName + "$ext";
    return file.rename(newPath);
  }

  Widget showBookCover() {
    if(_book.cover.isEmpty) {
      return const Text(
          "No cover image for this book",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          color: kErrorColorLight
        ),
      );
    } else {
      return _validURL? Image.network(_book.cover) : Image.file(
          File(_book.cover));
    }
  }
}
