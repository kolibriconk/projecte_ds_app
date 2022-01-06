import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/page_intervals.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/requests.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

class PageRecent extends StatefulWidget {
  final List<Activity> recent;
  final int size;
  const PageRecent(this.recent,this.size, {Key? key}) : super(key: key);

  @override
  _PageRecentState createState() => _PageRecentState();
}

class _PageRecentState extends State<PageRecent> {

  late final int size;
  late final List<Activity> recent;

  @override
  void initState() {
    super.initState();
    size = widget.size;
    recent = widget.recent;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // anonymous function
          return Scaffold(
            appBar: AppBar(
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: size,
              itemBuilder: (BuildContext context, int index) =>
                  _buildRow(recent![index], index),
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
            ),
          );
      },
    );

  }

  Widget _buildRow(Activity activity, int index) {
    String strDuration =
        Duration(seconds: activity.duration).toString().split('.').first;
    // split by '.' and taking first element of resulting list removes the microseconds part
    if (activity is Project) {
      return ListTile(
        leading: const Icon(Icons.folder),
        title: Text(activity.name),
        trailing: Text(strDuration),
        onTap: () =>
            _navigateDownActivities(activity.id, activity.tagList.join(",")),
      );
    } else if (activity is Task) {
      Task task = activity;
      // at the moment is the same, maybe changes in the future
      //Widget trailing = Text('$strDuration');
      Widget trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strDuration),
        ],
      );
      return ListTile(
        leading: const Icon(Icons.assignment),
        title: Text(activity.name),
        trailing: trailing,
        onTap: () => _navigateDownIntervals(activity.id),
      );
    } else {
      throw (Exception("Activity that is neither a Task or a Project")); //TODO EXCEPTION
      // this solves the problem of return Widget is not nullable because an
      // Exception is also a Widget?
    }
  }

  void _navigateDownActivities(int childId, String tags) {
    // we can not do just _refresh() because then the up arrow doesn't appear in the appbar
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => PageActivities(childId, tags),
    ));
  }

  void _navigateDownIntervals(int childId) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId),
    ));
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
  }

  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again"
    // therefore when going up
    super.dispose();
  }
}
