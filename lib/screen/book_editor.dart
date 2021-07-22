import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep/model/book.dart';

import '../styles.dart';

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
          Image.file(
                  File(_book.cover),
              ),
        ]
      ),
      ),
      ),
      ),
    );
  }
}
