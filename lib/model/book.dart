
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:keep/service/books_service.dart';

/// We make Book extends ChangeNotfier so that
/// every changes on this model will be notified

class Book extends ChangeNotifier {
  final String id;
  String title;
  String cover;
  final DateTime createdAt;
  DateTime modifiedAt;

  Book({
    this.id,
    this.title,
    this.cover,
    DateTime createdAt,
    DateTime modifiedAt
  }) : this.createdAt = createdAt ?? DateTime.now(),
  this.modifiedAt = modifiedAt ?? DateTime.now();

  static List<Book> fromQuery(QuerySnapshot snapshot) => snapshot != null ? toBooks(snapshot) : [];

  /// Serializes this book into a JSON object.
  Map<String, dynamic> toJson() => {
    'title': title,
    'cover': cover,
    'createdAt': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    'modifiedAt': (modifiedAt ?? DateTime.now()).millisecondsSinceEpoch,
  };

  Future<void> addBook(String uid) async {
   final bookCol = booksCollection(uid);

    await bookCol
        .add(toJson())
        .whenComplete(() => print("Notes item added to the database"));
  }

  Future<void> updateBook(String uid) async {
    final bookCol = booksCollection(uid);

    await bookCol
        .document(id)
        .updateData(toJson())
        .whenComplete(() => print("Note item updated in the database"))
        .catchError((e) => print(e));
  }
}

List<Book> toBooks(QuerySnapshot query) => query.documents
    .map((d) => toBook(d))
    .where((n) => n != null)
    .toList();

Book toBook(DocumentSnapshot doc) => doc.exists
    ? Book(
  id: doc.documentID,
  title: doc.data['title'],
  cover: doc.data['cover'],
  createdAt: DateTime.fromMillisecondsSinceEpoch(doc.data['createdAt'] ?? 0),
  modifiedAt: DateTime.fromMillisecondsSinceEpoch(doc.data['modifiedAt'] ?? 0),
) : null;