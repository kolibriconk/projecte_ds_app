import 'dart:async';

import 'package:codelab_timetracker/page_activities.dart';
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/tree.dart' as Tree hide getTree;

// to avoid collision with an Interval class in another library
import 'package:codelab_timetracker/requests.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'floating_action_button.dart';

class PageIntervals extends StatefulWidget {
  final int id;

   const PageIntervals(this.id, {Key? key}) : super(key: key);

  @override
  _PageIntervalsState createState() => _PageIntervalsState();
}

class _PageIntervalsState extends State<PageIntervals> {
  late int id;
  late Future<Tree.Tree> futureTree;

  late Timer _timer;
  static const int periodeRefresh = 6;

  late DateFormat dateFormat;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = getTree(id);
    _activateTimer();
    initializeDateFormatting();
    dateFormat = DateFormat(Intl.systemLocale);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree.Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          Tree.Activity activity = snapshot.data!.root;
          Tree.Task task = snapshot.data!.root as Tree.Task;
          int numChildren = activity.children.length;
          return Scaffold(
            appBar: AppBar(
              title: Text(task.name),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    //TODO: Funcionalidad de editar
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!.task+' : '+task.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppLocalizations.of(context)!.tags+" :"),
                              const SizedBox(height: 20),
                              Text(task.tagList.join(",") == ""
                                  ? AppLocalizations.of(context)!.noTags
                                  : task.tagList.join(",")),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, AppLocalizations.of(context)!.cancel),
                              child: Text(AppLocalizations.of(context)!.close),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.info)),
                IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {
                      while (Navigator.of(context).canPop()) {
                        print("pop");
                        Navigator.of(context).pop();
                      }
                      /* this works also:
    Navigator.popUntil(context, ModalRoute.withName('/'));
  */
                      PageActivities(0, "");
                    }),
              ],
            ),
            body: Column(
              children: <Widget>[
                _buildInfo(task),
                Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(AppLocalizations.of(context)!.tags+" : ", style: TextStyle(fontSize: 20)),
                  ),
                ]),
                const Divider(
                  color: Colors.black,
                ),
                Expanded(
                  child: ListView.separated(
                    // it's like ListView.builder() but better because it includes a separator between items
                    padding: const EdgeInsets.all(16.0),
                    itemCount: task.tagList.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _buildTags(task.tagList[index]),
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 2,
                  color: Colors.black,
                ),
                Expanded(
                  //        <-- Use Expanded
                  child: ListView.separated(
                    // it's like ListView.builder() but better because it includes a separator between items
                    padding: const EdgeInsets.all(16.0),
                    itemCount: numChildren,
                    itemBuilder: (BuildContext context, int index) =>
                        _buildRow(task.children[index], index),
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (task.active) {
                            stop(activity.id);
                          } else {
                            start(activity.id);
                          }
                          _refresh();
              },
              child: Icon(
                task.active ? Icons.stop : Icons.play_arrow,
              ),
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

  Widget _buildInfo(Tree.Activity task) {
    String strDuration =
        Duration(seconds: task.duration).toString().split('.').first;
    String strInitialDate = task.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    String strFinalDate = task.finalDate.toString().split('.')[0];
    return Column(
      children: [
        const Divider(
          thickness: 20,
          color: Colors.white,
        ),
        Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                const Divider(),
                const Icon(Icons.access_time_outlined),
                const SizedBox(
                  width: 10,
                ),
                Text(AppLocalizations.of(context)!.totalTime+' '+strDuration,
                    textAlign: TextAlign.left, overflow: TextOverflow.visible)
              ],
            )),
        const Divider(),
        Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                const Divider(),
                const Icon(Icons.access_time_outlined),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Text(AppLocalizations.of(context)!.firstTime + ' ' + DateFormat.yMMMMd(Localizations.localeOf(context).toString()).add_jms().format(DateTime.parse(strInitialDate)),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.visible))
              ],
            )),
        const Divider(),
        Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                const Divider(),
                const Icon(Icons.access_time_outlined),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Text(AppLocalizations.of(context)!.lastActivity + ' '+ DateFormat.yMMMMd(Localizations.localeOf(context).toString()).add_jms().format(DateTime.parse(strFinalDate)),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.visible))
              ],
            )),
        const Divider(),
      ],
    );
  }

  Widget _buildRow(Tree.Interval interval, int index) {
    String strDuration =
        Duration(seconds: interval.duration).toString().split('.').first;
    String strInitialDate = interval.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    String strFinalDate = interval.finalDate.toString().split('.')[0];

    return ListTile(
      title: Text(
        AppLocalizations.of(context)!.from + ' ' + DateFormat.yMMMMd(Localizations.localeOf(context).toString()).add_jms().format(DateTime.parse(strInitialDate)) + ' ' +
        AppLocalizations.of(context)!.to + ' ' +  DateFormat.yMMMMd(Localizations.localeOf(context).toString()).add_jms().format(DateTime.parse(strFinalDate))
          ),
      trailing: Text('$strDuration'),
    );
  }

  Widget _buildTags(String tag) {
    return ListTile(
      title: Text(tag),
    );
  }

  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }

  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again"
    // therefore when going up
    _timer.cancel();
    super.dispose();
  }
}
