import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep/model/book.dart';
import 'package:keep/model/camera_source.dart';
import 'package:keep/model/filter.dart';
import 'package:keep/model/note.dart';
import 'package:keep/model/user.dart';
import 'package:keep/service/books_service.dart';
import 'package:keep/service/notes_service.dart';
import 'package:keep/widget/books_grid.dart';
import 'package:keep/widget/books_list.dart';
import 'package:keep/widget/drawer.dart';
import 'package:keep/widget/notes_grid.dart';
import 'package:keep/widget/notes_list.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

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
            body: CustomScrollView(
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
                ),
            drawer: AppDrawer(),
            floatingActionButton: _fab(context),
            bottomNavigationBar: _bottomActions(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            extendBody: true,
          ),
        ),
      );

  Widget _appBar(BuildContext context) => SliverAppBar(
    floating: true,
    snap: true,
    title: _topActions(context),
    centerTitle: true,
    titleSpacing: 0,
    backgroundColor: Colors.transparent,
    elevation: 0,
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

  Widget _bottomActions() => BottomAppBar(
        shape: const CircularNotchedRectangle(),
        /*child: Container(
          height: kBottomBarSize,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Row(
            children: <Widget>[
              const Icon(AppIcons.checkbox, size: 26, color: kIconTintLight),
              const SizedBox(width: 30),
              const Icon(AppIcons.brush_sharp, size: 26, color: kIconTintLight),
              const SizedBox(width: 30),
              const Icon(AppIcons.mic, size: 26, color: kIconTintLight),
              const SizedBox(width: 30),
              const Icon(AppIcons.insert_photo,
                  size: 26, color: kIconTintLight),
            ],
          ),
        ),*/
      );

  Widget _fab(BuildContext context) => FloatingActionButton.extended(
      backgroundColor: Theme.of(context).accentColor,
      //child: const Icon(Icons.add),
      heroTag: null,
      icon: Icon(Icons.add),
      label: Text("New Book"),
      onPressed: openCamera
      /*onPressed: () async {
          final command = await Navigator.pushNamed(context, '/note');
          debugPrint('--- noteEditor result: $command');
          processNoteCommand(_scaffoldKey.currentState, command);
        },*/
      );

  void openCamera() async {
    debugPrint("opening Camera");
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: firstCamera, cameraSource: CameraSource.book)),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final url = Provider.of<CurrentUser>(context)?.data?.photoUrl;
    return CircleAvatar(
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null ? const Icon(Icons.face) : null,
      radius: isNotAndroid ? 19 : 17,
    );
  }

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

  /// Create notes query
  Stream<List<Book>> _createBookStream(BuildContext context) {
    final user = Provider.of<CurrentUser>(context)?.data;
    final collection = booksCollection(user?.uid);

    return collection
        .snapshots()
        .handleError((e) => debugPrint('query books failed: $e'))
        .map((snapshot) => Book.fromQuery(snapshot));
  }
}