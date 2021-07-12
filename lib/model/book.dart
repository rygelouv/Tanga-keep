
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

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