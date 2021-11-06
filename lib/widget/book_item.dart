import 'package:flutter/material.dart';
import 'package:keep/model/book.dart';

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
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(book.cover),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          textAlign: TextAlign.start),
                    ),
                    Text("Taken notes #10",
                        style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 11),
                        textAlign: TextAlign.start)
                  ],
                ),
              )
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 3,
          margin: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
