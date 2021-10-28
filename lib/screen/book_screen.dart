import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep/model/book.dart';
import 'package:keep/widget/books_grid.dart';
import 'package:provider/provider.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({Key key}) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        _appBar(context), // a floating appbar
        const SliverToBoxAdapter(
          child: SizedBox(height: 24), // top spacing
        ),
        _buildBooksView(context),
        const SliverToBoxAdapter(
          child: SizedBox(
              height:
              80.0), // bottom spacing make sure the content can scroll above the bottom bar
        ),
      ],
    );
  }

  Widget _appBar(BuildContext context) => SliverAppBar(
    floating: true,
    snap: true,
    title: Text("Home",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Theme.of(context).accentColor
        )
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  );


  /// A grid/list view to display notes
  ///
  /// Notes are divided to `Pinned` and `Others` when there's no filter,
  /// and a blank view will be rendered, if no note found.
  Widget _buildBooksView(BuildContext context) => Consumer<List<Book>>(
    builder: (context, books, _) {
      if (books?.isNotEmpty != true) {
        return _buildBlankView();
      }

      final widget = BooksGrid.create;

      return widget(books: books, onTap: _onBookTap);
    },
  );

  Widget _buildBlankView() => const SliverFillRemaining(
    hasScrollBody: false,
    child: Text(
      'Notes you add appear here',
      style: TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
    ),
  );

  /// Callback on a single book clicked
  void _onBookTap(Book book) async {
    await Navigator.pushNamed(context, '/note', arguments: {'book': book});
  }
}
