import 'package:cloud_firestore/cloud_firestore.dart';

/*
  For now this file will only contain
  the return of every nodes in books collections
  Willing to respect the FireBase structure, we will embed
  Notes collection in the books collection
  So that once we get the book collection
  we get every book's notes
*/


/// Returns reference to the books collection of the user [uid].
CollectionReference booksCollection(String uid) => Firestore.instance.collection('books-$uid');

/// Returns reference to the given book [id] of the user [uid].
DocumentReference bookDocument(String id, String uid) => booksCollection(uid).document(id);

/// Returns reference to the notes collection embedded in book collection
CollectionReference notesCollection(String id, String uid) => bookDocument(id, uid).collection('notes');