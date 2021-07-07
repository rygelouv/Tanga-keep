import 'package:flutter/cupertino.dart';
import 'package:keep/model/book.dart';

class BooksList extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onTap;

  const BooksList({
    Key key,
    @required this.books,
    this.onTap}) : super(key: key);

  static BooksList create({
    Key key,
    @required List<Book> books,
    void Function(Book) onTap,
  }) => BooksList(
    key: key,
    books: books,
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
