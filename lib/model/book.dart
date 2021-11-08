
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:keep/service/books_service.dart';

/// We make Book extends ChangeNotfier so that
/// every changes on this model will be notified

class Book extends ChangeNotifier {
  final String id;
  String title;
  String cover;
  BookState state;
  final DateTime createdAt;
  DateTime modifiedAt;

  Book({
    this.id,
    this.title,
    this.cover,
    this.state,
    DateTime createdAt,
    DateTime modifiedAt
  }) : this.createdAt = createdAt ?? DateTime.now(),
  this.modifiedAt = modifiedAt ?? DateTime.now();

  static List<Book> fromQuery(QuerySnapshot snapshot) => snapshot != null ? toBooks(snapshot) : [];

  /// Serializes this book into a JSON object.
  Map<String, dynamic> toJson() => {
    'title': title,
    'cover': cover,
    'state': state,
    'createdAt': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    'modifiedAt': (modifiedAt ?? DateTime.now()).millisecondsSinceEpoch,
  };

  Future<void> addBook(String uid) async {
   final bookCollection = booksCollection(uid);

    await bookCollection
        .add(toJson())
        .whenComplete(() => print("Book item added to the database"));
  }

  Future<void> updateBook(String uid) async {
    final bookCollection = booksCollection(uid);

    await bookCollection
        .doc(id)
        .update(toJson())
        .whenComplete(() => print("Book item updated in the database"))
        .catchError((e) => print(e));
  }
}

List<Book> toBooks(QuerySnapshot query) => query.docs
    .map((d) => toBook(d))
    .where((n) => n != null)
    .toList();

Book toBook(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  if(data.isNotEmpty)
    return Book(
  id: doc.id,
  title: data['title'],
  cover: data['cover'],
  state: BookState.values[data['state'] ?? 0],
  createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
  modifiedAt: DateTime.fromMillisecondsSinceEpoch(data['modifiedAt'] ?? 0),
  );  else return null;
}

enum BookState {
  active,
  deleted
}
