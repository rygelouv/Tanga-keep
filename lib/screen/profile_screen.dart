import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep/model/user.dart';
import 'package:keep/screens.dart';
import 'package:provider/provider.dart';

import '../styles.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        _appBar(context),
        SliverFillRemaining(
          hasScrollBody: true,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: kNewAccentColor,
                    minRadius: 60.0,
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL)
                          : AssetImage('assets/images/avatar.png'),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                user.displayName,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                user.email,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(top: 26.0, left: 16.0, bottom: 10.0),
                    child: Text(
                      'Account',
                      style: TextStyle(
                        color: kNewAccentColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: InkWell(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.notifications),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Notification",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: InkWell(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.check_box),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "My Plan",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: InkWell(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.lock),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Password",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: InkWell(
                      onTap: () => _signOut(context),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.logout),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Logout",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                    EdgeInsets.only(top: 24.0, left: 16.0, bottom: 10.0),
                    child: Text(
                      'Share',
                      style: TextStyle(
                        color: kNewAccentColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _signOut(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Are you sure to sign out the current account?'),
        actions: <Widget>[
          FlatButton(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: const Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (yes) {
      FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  Widget _appBar(BuildContext context) => SliverAppBar(
        floating: true,
        snap: true,
        title: Text("Profile",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Theme.of(context).accentColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
}
