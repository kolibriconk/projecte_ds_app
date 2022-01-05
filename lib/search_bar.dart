import 'package:codelab_timetracker/page_activities.dart';
import 'package:flutter/material.dart';


class SearchBar extends StatefulWidget {
  final List<String> tagList;
  const SearchBar(this.tagList, {Key? key}) : super(key: key); //go back main menu

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>{

  _SearchBarState() {
    _filter.addListener((){
      if(_filter.text.isEmpty){
        setState(() {
          _searchText = "No tags founds";
          filteredTags = tagList;
        });
      }
      else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    }
    );
  }

  final TextEditingController _filter = TextEditingController();
  String _searchText = "";
  late List<String> tagList; // new List() tags //TODO GET TAGLIST & GET ID PROJECT
  List<String> filteredTags = ['']; //tags filtered by search
  Icon _searchIcon =  const Icon(Icons.search);
  Widget _appBarTitle = Text('Search');

  @override
  void initState() {
    super.initState();
    tagList = widget.tagList;
  }

  void _getTags() async {
    //TODO 1
   /* final response = Listags;*/
  }

  void _searchPressed(){
    setState(() {
      if(_searchIcon.icon == Icons.search) {
        _searchIcon = const Icon(Icons.close); //new Icon = error Icons.close as Icon
        _appBarTitle = TextField( //change title to search bar
          controller: _filter,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search), hintText: 'Type tag...'
          ),
        );
      }
      else {
        _searchIcon = const Icon(Icons.search);
        filteredTags = tagList;
        _filter.clear();
      }
    });
  }

  /*Widget _buildList(BuildContext context) { //Result of search
    if(_searchText.isNotEmpty) {
    }
  }*/
  /*Find tags*/
  Widget _BuildList() {
    //TODO SEARCH
    if(_searchText.isNotEmpty){
      List<String> tempList = <String>[];
      for(int i = 0; i < tagList.length; i++){
        if(tagList[i]
            .toLowerCase()
            .contains(_searchText.toLowerCase())){
          tempList.add(tagList[i]);
        }
      }
      filteredTags = tempList;
    }
    else {
      filteredTags = ['No tags found'];
    }
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          //TODO print Task&Projects
          title: Text(filteredTags.toString()),
          /*onTap: () => print(filteredTags),*/
        );
      },
    );
  }
  /*AppBar*/
  AppBar _AppBar() {
    return AppBar(
        centerTitle: true,
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            color: Colors.white,
            onPressed: _searchPressed,
            iconSize: 50,
            )
        ]
    );
  }

  /*BottomBar*/
  Widget _BottomAppBar(){
    return BottomAppBar(
      child: ElevatedButton(
        child: const Text('Back Main Menu'),
        onPressed: () {
          Navigator.pop(
            context,
            MaterialPageRoute(builder: (context) => const PageActivities(0, "")),
          );
        },
      ),
    );
/*    )?*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _AppBar(),
        body: Container(
          child: _BuildList(),
        ),
        bottomNavigationBar: _BottomAppBar(),
    );
  }
  }


