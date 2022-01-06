import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/page_intervals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /*title: 'TimeTracker',*/
      //locale: Locale('en'),
      onGenerateTitle: (context) =>
        AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
            subtitle1: TextStyle(fontSize: 20.0),
            bodyText2: TextStyle(fontSize: 20.0)),
      ),
      home: PageActivities(0, ""),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new PageActivities(0, "")
      },
    );
  }
}
