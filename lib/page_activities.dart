import 'package:codelab_timetracker/floating_action_button.dart';
import 'package:codelab_timetracker/page_intervals.dart';
import 'package:codelab_timetracker/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:codelab_timetracker/requests.dart';
import 'dart:async';

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

  late Timer _timer;
  static const int periodRefresh = 6;

  TextEditingController nameController = TextEditingController();
  TextEditingController tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    id = widget.id;
    tagList = widget.tagList;
    futureTree = getTree(id);
    _activateTimer();
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
                IconButton(
                    onPressed: (){
                      //TODO: Funcionalidad de buscar
                    },
                    icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: (){
                    //TODO: Funcionalidad de editar
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('Proyecto: ${snapshot.data!.root.name}'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Tags:"),
                              const SizedBox(height: 20),
                              Text(snapshot.data!.root.tagList.join(",") == ""
                                  ? "Sin tags"
                                  : snapshot.data!.root.tagList.join(",")),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.info)),
                IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      while (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      PageActivities(0, snapshot.data!.root.tagList.join(","));
                    }),
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
                      title: const Text('Nuevo proyecto'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Nombre",
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: tagController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Tags (Separados por coma)",
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => {
                            addActivity(nameController.text, id, true,
                                tagController.text),
                            Navigator.pop(context, 'Cancel'),
                            nameController.text = "",
                            tagController.text = "",
                            _refresh(),
                          },
                          child: const Text('Añadir'),
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
                      title: const Text('Nueva tarea'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Nombre",
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: tagController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Tags (Separados por coma)",
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => {
                            addActivity(nameController.text, id, false,
                                tagController.text),
                            Navigator.pop(context, 'Cancel'),
                            nameController.text = "",
                            tagController.text = "",
                            _refresh(),
                          },
                          child: const Text('Añadir'),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.assignment),
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
        onTap: () => _navigateDownIntervals(activity.id),
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
      _activateTimer();
      _refresh();
    });
  }

  void _navigateDownIntervals(int childId) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId),
    ))
        .then((var value) {
      _activateTimer();
      _refresh();
    });
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
  }

  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }

  void _activateTimer() {
    _timer = Timer.periodic(const Duration(seconds: periodRefresh), (Timer t) {
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
