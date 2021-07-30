import 'dart:io';

import 'package:flutter/material.dart';
import 'package:keep/model/book.dart';
import 'package:keep/model/note.dart';

import '../styles.dart';

/// A single item (preview of a Note) in the Notes list.
class BookItem extends StatelessWidget {
  const BookItem({
    Key key,
    this.book,
  }) : super(key: key);

  final Book book;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          height: 700,
          child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
        children: <Widget> [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 130,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(book.cover),
              ),
            ),
          ),
          Text(book.title, textAlign: TextAlign.start,)
            ],
          ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            margin: EdgeInsets.all(10),
        ),
        ),
    );
  }
}
