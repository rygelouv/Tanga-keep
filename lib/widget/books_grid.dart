import 'package:flutter/material.dart';
import 'package:keep/model/book.dart';
import 'package:keep/model/note.dart';



import 'note_item.dart';

/// Grid view of [Note]s.
class BooksGrid extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onTap;

  const BooksGrid({
    Key key,
    @required this.books,
    this.onTap,
  }) : super(key: key);

  static BooksGrid create({
    Key key,
    @required List<Book> books,
    void Function(Book) onTap,
  }) => BooksGrid(
    key: key,
    books: books,
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
