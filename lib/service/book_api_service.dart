import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class BookServiceApi {
  //Book isbn
  String bookIsbn;
  //Api url
  Uri url;
  //ApiKey
  final apikey = 'AIzaSyB1TiwnZ5Ze753IInGX_yNVgIQBWY2O2Z8';

  BookServiceApi(String bookIsbn) {
    this.bookIsbn = bookIsbn;
    this.url = buildUrl();
  }

  Uri buildUrl() {
    return Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{$bookIsbn}', 'apikey': '{ $apikey }' });
  }

  //Method to execute the request
  Future<Response> execute() async {
    var response = http.get(url);
    return response;
  }


}