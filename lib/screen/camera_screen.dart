import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:keep/model/book.dart';
import 'package:keep/model/camera_source.dart';
import 'package:keep/model/note.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'home_screen.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final CameraSource cameraSource;
  final Book book;

  const TakePictureScreen({
    Key key,
    @required this.camera,
    @required this.cameraSource, this.book,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState(book);
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  TakePictureScreenState(this._book);

  Book _book;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan the page')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).accentColor,
        heroTag: null,
        icon: Icon(Icons.camera_alt),
        label: Text("Capture"),
        //child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            final image = await _controller.takePicture();

            switch(widget.cameraSource) {
              case CameraSource.book:
                saveBookData(image.path);
                debugPrint("#### Book cover ######");
                break;
              case CameraSource.note:
                File croppedFile = await ImageCropper.cropImage(
                    sourcePath: image.path,
                    aspectRatioPresets: [
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio3x2,
                      CropAspectRatioPreset.original,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.ratio16x9
                    ],
                    androidUiSettings: AndroidUiSettings(
                        toolbarTitle: 'Crop your note',
                        toolbarColor: Colors.black,
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.original,
                        lockAspectRatio: false),
                    iosUiSettings: IOSUiSettings(
                      minimumAspectRatio: 1.0,
                    ));
                getTextFromImage(croppedFile.path);

                break;
            }
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void openCroppingScreen(String path) {}

  void getTextFromImage(String imagePath) async {
    final File imageFile = File(imagePath);
    final textDetector = GoogleMlKit.vision.textDetector();
    final visionImage = InputImage.fromFile(imageFile);
    final RecognisedText recognisedText = await textDetector.processImage(visionImage);
    String text = recognisedText.text;
    debugPrint(text);

    Note note = Note(content: text);
    final command = await Navigator.pushNamed(context, '/note_editor',
        arguments: {'note': note, 'bookId': _book.id});
    debugPrint('--- noteEditor result: $command');

    // If the picture was taken, display it on a new screen.
    // navigateToNextScreen(imagePath);
  }

  void navigateToNextScreen(String path) async {
    //processNoteCommand(_scaffoldKey.currentState, command);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(imagePath: path),
      ),
    );
  }

  void saveBookData(String path) async {
    print("------------------- Book saving --------------------");
    _book.cover = path;
    //Navigator.pop(context, _book);
   Navigator.pop(context);
    Navigator.of(context)
        .pushNamed('/book', arguments: {'book': _book});
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
