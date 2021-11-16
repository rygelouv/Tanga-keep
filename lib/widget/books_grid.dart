import 'package:flutter/material.dart';
import 'package:keep/model/book.dart';
import 'package:keep/model/note.dart';



import 'book_item.dart';
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
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    sliver: SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1 / 1.53,
      ),
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _bookItem(context, books[index]),
        childCount: books.length,
      ),
    ),
  );

  Widget _bookItem(BuildContext context, Book book) => InkWell(
    onTap: () => onTap?.call(book),
    child: BookItem(book: book),
  );
}
