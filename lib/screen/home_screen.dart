import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:keep/model/book.dart';
import 'package:keep/model/camera_source.dart';
import 'package:keep/model/filter.dart';
import 'package:keep/model/note.dart';
import 'package:keep/model/user.dart';
import 'package:keep/screen/book_screen.dart';
import 'package:keep/screen/profile_screen.dart';
import 'package:keep/service/book_api_service.dart';
import 'package:keep/service/books_service.dart';
import 'package:keep/service/notes_service.dart';
import 'package:keep/widget/books_grid.dart';
import 'package:keep/widget/books_list.dart';
import 'package:keep/widget/bottom_navigation.dart';
import 'package:keep/widget/drawer.dart';
import 'package:keep/widget/notes_grid.dart';
import 'package:keep/widget/notes_list.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import '../icons.dart';
import '../styles.dart';
import '../utils.dart';
import 'camera_screen.dart';

/// Home screen, displays [Note] grid or list.
class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

/// [State] of [HomeScreen].
class _HomeScreenState extends State<HomeScreen> with CommandHandler {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// `true` to show notes in a GridView, a ListView otherwise.
  bool _gridView = true;
  int _selectedIndex = 0;

  static List<Widget> _children = <Widget>[
   BookScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
//      statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: StreamProvider.value(
          value: _createBookStream(context),
          child: Scaffold(
            body: _children[_selectedIndex],
            floatingActionButton: _fab(context),
            bottomNavigationBar: _bottonNavigation(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            extendBody: true,
          ),
        ),
      );



  Widget _topActions(BuildContext context) => Container(
        // width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 720,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isNotAndroid ? 7 : 5),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 20),
                InkWell(
                  child: const Icon(Icons.menu),
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Tanga App',
                    softWrap: false,
                    style: TextStyle(
                      color: kHintTextColorLight,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  child:
                      Icon(_gridView ? AppIcons.view_list : AppIcons.view_grid),
                  onTap: () => setState(() {
                    _gridView = !_gridView;
                  }),
                ),
                const SizedBox(width: 18),
                _buildAvatar(context),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      );


  Widget _fab(BuildContext context) => FloatingActionButton(
      backgroundColor: Theme.of(context).accentColor,
      //child: const Icon(Icons.add),
      heroTag: null,
      child: Icon(Icons.add_outlined),
      onPressed: openScanner
      /*onPressed: () async {
          final command = await Navigator.pushNamed(context, '/note');
          debugPrint('--- noteEditor result: $command');
          processNoteCommand(_scaffoldKey.currentState, command);
        },*/
      );


  Widget _buildAvatar(BuildContext context) {
    final url = Provider.of<CurrentUser>(context)?.data?.photoURL;
    return CircleAvatar(
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null ? const Icon(Icons.face) : null,
      radius: isNotAndroid ? 19 : 17,
    );
  }

  /// Create notes query
  Stream<List<Book>> _createBookStream(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final collection = booksCollection(user?.uid);

    return collection
        .where('state',
        isLessThan: BookState.deleted
            .index)
        .snapshots()
        .handleError((e) => debugPrint('query books failed: $e'))
        .map((snapshot) => Book.fromQuery(snapshot));
  }

  void openScanner() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE);
    print('----------  $barcodeScanRes  -----------');



    /* Barcode scanner return -1 as a result when the user cancel the scan
      So to avoid the api call, I need to check the value here. Because there
      is no callback for the cancel button in the lib
     */
    if (barcodeScanRes != "-1") {
      // Await the http get response, then decode the json-formatted response.
      callApi(barcodeScanRes);
    }
  }

  void callApi(String bookIsbn) async {
    var response = await BookServiceApi(bookIsbn).execute();
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      var data = jsonResponse['items'].first['volumeInfo'];
      Book book = Book(title: data['title']);
      if (data['imageLinks'] == null) {
        book.cover = "";
      } else {
        book.cover = data['imageLinks']['thumbnail'];
      }
      print('Book ${book.title} ---- ${book.cover}----');
      Navigator.of(context)
          .pushNamed('/book', arguments: {'book': book});
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Widget _bottonNavigation() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.house_rounded), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile"),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).accentColor,
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}