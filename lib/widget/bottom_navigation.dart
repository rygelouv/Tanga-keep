import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      color: Colors.blueGrey,
      notchMargin: 2.0,
      clipBehavior: Clip.antiAlias,
      child: BottomNavigationBar(items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.house_rounded), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.watch_later), label: "Recent"),
      ],
          selectedItemColor: Theme.of(context).accentColor
      ),
    );
  }
}
