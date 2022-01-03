import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/page_intervals.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeTracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
            subtitle1: TextStyle(fontSize: 20.0),
            bodyText2: TextStyle(fontSize: 20.0)),
      ),
      home: PageActivities(0),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new PageActivities(0)
      },
    );
  }
}
