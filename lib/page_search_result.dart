import 'package:codelab_timetracker/page_activities.dart';
import 'package:codelab_timetracker/page_intervals.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/requests.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

class PageSearchResult extends StatefulWidget {
  final String tagToSearch;
  final int option;
  final int id;
  const PageSearchResult(this.tagToSearch,this.option,this.id, {Key? key}) : super(key: key);

  @override
  _PageSearchResultState createState() => _PageSearchResultState();
}

class _PageSearchResultState extends State<PageSearchResult> {
  late Future<ActivityList> futureActivityList;

  @override
  void initState() {
    super.initState();
    if(widget.option==0){
      futureActivityList = retrieveActivityList(widget.tagToSearch);
    }
    else{
      futureActivityList = retrieveActivityListChilds(widget.tagToSearch,widget.id);
    }

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActivityList>(
      future: futureActivityList,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.searchResult),
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.matchingList.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildRow(snapshot.data!.matchingList[index], index),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ));
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
        onTap: () => _navigateDownIntervals(activity.id, activity.tagList.join(",")),
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

  void _navigateDownIntervals(int childId, String tags) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId, tags),
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
