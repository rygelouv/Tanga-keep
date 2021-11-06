import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep/model/book.dart';
import 'package:keep/widget/books_grid.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../styles.dart';

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
    toolbarHeight: 250,
    title: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /*CircleAvatar(
          backgroundColor: kNewAccentColor,
          minRadius: 5.0,
          child: CircleAvatar(
            radius: 15.0,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
        ),*/
        Padding(
          padding: EdgeInsets.only(left: 15, top: 10),
          child: Text(
            "Hi,",
            style: TextStyle(
                color: kHintTextColorLight
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15),
          child: Text(
            "Rygel",
            style: TextStyle(
                color: kNewAccentColor,
                fontSize: 28
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            margin: EdgeInsets.only(left: 0, top: 10),
            child: Card(
              color: kNewAccentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 3,
              child: Container(
                height: 135,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                            "Notes taken",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 17,
                                color: Colors.white
                            )
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "35",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                color: Colors.white
                            )
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Text("\"Books are a uniquely portable magic\"",
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    color: Colors.grey
                                ),
                              )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
