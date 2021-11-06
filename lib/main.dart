
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:google_fonts/google_fonts.dart';
import 'package:keep/screen/book_editor.dart';
import 'package:keep/screen/note_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:provider/provider.dart';

import 'models.dart' show CurrentUser;
import 'screens.dart' show HomeScreen, LoginScreen, NoteEditor, SettingsScreen;
import 'styles.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initPlatformState();
  runApp(NotesApp());
}

Future<void> initPlatformState() async {
  //Remove this method to stop OneSignal Debugging
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId("00e4ca93-54c7-4c34-b9d4-ba4195bb36da");

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });
}

class NotesApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => StreamProvider.value(
    value: FirebaseAuth.instance.authStateChanges().map((user) => CurrentUser.create(user)),
    initialData: CurrentUser.initial,
    child: Consumer<CurrentUser>(
      builder: (context, user, _) => MaterialApp(
        title: 'Flutter Keep',
        theme: Theme.of(context).copyWith(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          accentColor: kNewAccentColor,
          appBarTheme: AppBarTheme.of(context).copyWith(
            elevation: 0,
            backgroundColor: Colors.white,
            brightness: Brightness.light,
            iconTheme: IconThemeData(
              color: kNewAccentColor,
            ),
          ),
          scaffoldBackgroundColor: kBorderColorLightGray,
          bottomAppBarColor: Colors.white,
          bottomAppBarTheme: BottomAppBarTheme(
            shape: CircularNotchedRectangle(),
          ),
          textTheme: GoogleFonts.montserratTextTheme(
              Theme.of(context).textTheme
          ),
          primaryTextTheme: GoogleFonts.montserratTextTheme(
              Theme.of(context).primaryTextTheme.copyWith(
                // title
                headline6: const TextStyle(
                  color: kIconTintLight,
                ),
              )
          ),
        ),
        navigatorObservers: <NavigatorObserver>[observer],
        home: user.isInitialValue
          ? Scaffold(body: const SizedBox())
          : user.data != null ? HomeScreen() : LoginScreen(),
        routes: {
          '/settings': (_) => SettingsScreen(),
        },
        onGenerateRoute: _generateRoute,
      ),
    ),
  );

  /// Handle named route
  Route _generateRoute(RouteSettings settings) {
    try {
      return _doGenerateRoute(settings);
    } catch (e, s) {
      debugPrint("failed to generate route for $settings: $e $s");
      return null;
    }
  }

  Route _doGenerateRoute(RouteSettings settings) {
    if (settings.name?.isNotEmpty != true) return null;

    final uri = Uri.parse(settings.name);
    final path = uri.path ?? '';
    // final q = uri.queryParameters ?? <String, String>{};
    switch (path) {
      case '/note_editor': {
        final note = (settings.arguments as Map ?? {})['note'];
        final bookId = (settings.arguments as Map ?? {})['bookId'];
        return _buildRoute(settings, (_) => NoteEditor(note: note, bookId: bookId));
      }
      case '/book': {
        final book = (settings.arguments as Map ?? {})['book'];
        return _buildRoute(settings, (_) => BookEditor(book: book));
      }
      case '/note': {
        final book = (settings.arguments as Map ?? {})['book'];
        return _buildRoute(settings, (_) => NoteScreen(book: book));
      }
      default:
        return null;
    }
  }


  /// Create a [Route].
  Route _buildRoute(RouteSettings settings, WidgetBuilder builder) =>
    MaterialPageRoute<void>(
      settings: settings,
      builder: builder,
    );
}
