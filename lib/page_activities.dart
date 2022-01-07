import 'package:codelab_timetracker/floating_action_button.dart';
import 'package:codelab_timetracker/page_intervals.dart';
import 'package:codelab_timetracker/page_recent.dart';
import 'package:codelab_timetracker/page_search_result.dart';
import 'package:codelab_timetracker/main.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/requests.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

// ignore: must_be_immutable
class PageActivities extends StatefulWidget {
  final int id;
  final String tagList;

  const PageActivities(this.id, this.tagList, {Key? key}) : super(key: key);

  @override
  _PageActivitiesState createState() => _PageActivitiesState();
}

class _PageActivitiesState extends State<PageActivities> {
  late int id;
  late String tagList;
  late Future<Tree> futureTree;
  late int option;

  //late List<int> recentList;

  late Timer _timer;
  static const int periodRefresh = 6;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    id = widget.id;
    tagList = widget.tagList;
    futureTree = getTree(id, 0);
    //recentList = [];
    _activateTimer();
    option = 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.root.name),
              actions: <Widget>[
                _buildSearch(),
                Visibility(
                  visible: snapshot.data!.root.id != 0,
                  child: IconButton(
                    onPressed: () {
                      _nameController.text = snapshot.data!.root.name;
                      _tagController.text = tagList;
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(
                              AppLocalizations.of(context)!.editProjectText),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: AppLocalizations.of(context)!.name,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _tagController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: AppLocalizations.of(context)!
                                      .tagLabelText,
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context,
                                  AppLocalizations.of(context)!.cancel),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () => {
                                editActivity(_nameController.text, id,
                                    _tagController.text),
                                Navigator.pop(context,
                                    AppLocalizations.of(context)!.cancel),
                                _nameController.text = "",
                                _tagController.text = "",
                                _refresh(),
                              },
                              child: Text(AppLocalizations.of(context)!.edit),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!.project +
                              ' : ' +
                              snapshot.data!.root.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppLocalizations.of(context)!.tags + ' : '),
                              const SizedBox(height: 20),
                              Text(snapshot.data!.root.tagList.join(",") == ""
                                  ? AppLocalizations.of(context)!.noTags
                                  : snapshot.data!.root.tagList.join(",")),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context,
                                  AppLocalizations.of(context)!.cancel),
                              child: Text(AppLocalizations.of(context)!.close),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.info)),
              ],
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.root.children.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildRow(snapshot.data!.root.children[index], index),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
            floatingActionButton: ExpandableFab(
              distance: 60.0,
              children: [
                ActionButton(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.newProject),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: AppLocalizations.of(context)!.name,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText:
                                  AppLocalizations.of(context)!.tagLabelText,
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(
                              context, AppLocalizations.of(context)!.cancel),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () => {
                            addActivity(_nameController.text, id, true,
                                _tagController.text),
                            Navigator.pop(
                                context, AppLocalizations.of(context)!.cancel),
                            _nameController.text = "",
                            _tagController.text = "",
                            _refresh(),
                          },
                          child: Text(AppLocalizations.of(context)!.add),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.folder),
                ),
                ActionButton(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.newTask),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: AppLocalizations.of(context)!.name,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText:
                                  AppLocalizations.of(context)!.tagLabelText,
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(
                              context, AppLocalizations.of(context)!.cancel),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () => {
                            addActivity(_nameController.text, id, false,
                                _tagController.text),
                            Navigator.pop(
                                context, AppLocalizations.of(context)!.cancel),
                            _nameController.text = "",
                            _tagController.text = "",
                            _refresh(),
                          },
                          child: Text(AppLocalizations.of(context)!.add),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.assignment),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.blue,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              onTap: (newIndex) {
                switch (newIndex) {
                  case 0:
                    option = (option + 1) % 3;
                    _refresh();
                    String message = AppLocalizations.of(context)!.sortingType;
                    if (option == 1) {
                      message = AppLocalizations.of(context)!.sortingAlphabetical;
                    } else if (option == 2) {
                      message = AppLocalizations.of(context)!.sortingCreation;
                    }
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                    ));
                    break;
                  case 1:
                    while (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    PageActivities(0, snapshot.data!.root.tagList.join(","));
                    break;
                  case 2:
                    Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (context) =>
                          PageRecent(MyApp.recentList, MyApp.recentList.length),
                    ));
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.sort), label: 'Order'),
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shortcut),
                  label: 'Recents',
                ),
              ],
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

  Widget _buildSearch() {
    if (id == 0) {
      return IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.textTag),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _filterController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.textFiledTag,
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(
                        context, AppLocalizations.of(context)!.cancel),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_filterController.text != "") {
                        Navigator.pop(
                            context, AppLocalizations.of(context)!.cancel);
                        _navigateToResultSearch(_filterController.text);
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.search),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.search));
    } else {
      return IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.textTag),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _filterController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.textFiledTag,
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(
                        context, AppLocalizations.of(context)!.cancel),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_filterController.text != "") {
                        Navigator.pop(
                            context, AppLocalizations.of(context)!.cancel);
                        _navigateToResultSearchChilds(_filterController.text);
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.search),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.search));
    }
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
        onTap: () {
          _navigateDownActivities(activity.id, activity.tagList.join(","));
          if (!MyApp.recentList.contains(activity.id)) {
            MyApp.recentList.add(activity.id);
          }
        },
      );
    } else if (activity is Task) {
      Task task = activity;
      // at the moment is the same, maybe changes in the future
      //Widget trailing = Text('$strDuration');
      Widget trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strDuration),
          IconButton(
              onPressed: () {
                if (task.active) {
                  stop(activity.id);
                } else {
                  start(activity.id);
                }
                _refresh();
              },
              icon: Icon(
                task.active ? Icons.stop : Icons.play_arrow,
                size: 35,
              ))
        ],
      );
      return ListTile(
        leading: const Icon(Icons.assignment),
        title: Text(activity.name),
        trailing: trailing,
        onTap: () {
          _navigateDownIntervals(activity.id, activity.tagList.join(","));
          if (!MyApp.recentList.contains(activity.id)) {
            MyApp.recentList.add(activity.id);
          }
        },
      );
    } else {
      throw (Exception("Activity that is neither a Task or a Project"));
      // this solves the problem of return Widget is not nullable because an
      // Exception is also a Widget?
    }
  }

  void _navigateDownActivities(int childId, String tags) {
    // we can not do just _refresh() because then the up arrow doesn't appear in the appbar
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageActivities(childId, tags),
    ))
        .then((var value) {
      //_activateTimer();
      //_refresh();
    });
  }

  void _navigateDownIntervals(int childId, String tags) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId, tags),
    ))
        .then((var value) {
      //_activateTimer();
      //_refresh();
    });
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
  }

  void _navigateToResultSearch(String text) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => PageSearchResult(text, 0, 0),
    ));
  }

  void _navigateToResultSearchChilds(String text) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => PageSearchResult(text, 1, id),
    ));
  }

  void _refresh() async {
    futureTree = getTree(id, option); // to be used in build()
    setState(() {});
  }

  void _activateTimer() {
    _timer = Timer.periodic(const Duration(seconds: periodRefresh), (Timer t) {
      futureTree = getTree(id, option);
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
