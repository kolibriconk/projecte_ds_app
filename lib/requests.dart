import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'tree.dart';

final http.Client client = http.Client();
// better than http.get() if multiple requests to the same server

// If you connect the Android emulator to the webserver listening to localhost:8080
const String baseUrl = "http://192.168.137.1:8080"; // Para Jose
//const String baseUrl = "http://localhost:8080";

// If instead you want to use a real phone, you need ngrok to redirect
// localhost:8080 to some temporal Url that ngrok.com provides for free: run
// "ngrok http 8080" and replace the address in the sentence below
//const String baseUrl = "http://59c1d5a02fa5.ngrok.io";
// in linux I've installed ngrok with "sudo npm install ngrok -g". On linux, windows,
// mac download it from https://ngrok.com/. More on this here
// https://stackoverflow.com/questions/4779963/how-can-i-access-my-localhost-from-my-android-device
// https://newbedev.com/how-can-i-access-my-localhost-from-my-android-device
// look for "Portable solution with ngrok"

Future<Tree> getTree(int id, int option) async {
  var uri = Uri.parse("$baseUrl/get_tree?$id&$option");
  // see https://pub.dev/packages/http for examples of use
  final response = await client.get(uri);
  // response is NOT a Future because of await but since getTree() is async,
  // execution continues (leaves this function) until response is available,
  // and then we come back here
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    print(response.body);
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> decoded = convert.jsonDecode(response.body);
    return Tree(decoded);
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    print("statusCode=$response.statusCode");
    throw Exception('Failed to get children');
  }
}
Future<Tree> orderTree(int id,int option) async {
  var uri = Uri.parse("$baseUrl/orderTree?$id,$option");
  // see https://pub.dev/packages/http for examples of use
  final response = await client.get(uri);
  // response is NOT a Future because of await but since getTree() is async,
  // execution continues (leaves this function) until response is available,
  // and then we come back here
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    print(response.body);
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> decoded = convert.jsonDecode(response.body);
    return Tree(decoded);
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    print("statusCode=$response.statusCode");
    throw Exception('Failed to get children');
  }
}

Future<void> start(int id) async {
  var uri = Uri.parse("$baseUrl/start?$id");
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to get children');
  }
}

Future<void> stop(int id) async {
  var uri = Uri.parse("$baseUrl/stop?$id");
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to get children');
  }
}

Future<bool> addActivity(
    String name, int parentId, bool isProject, String tagList) async {
  var uri =
      Uri.parse("$baseUrl/addActivity?$name&$parentId&$isProject&$tagList");
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    Map<String, dynamic> decoded = convert.jsonDecode(response.body);
    return decoded['added'];
  } else {
    print("statusCode=$response.statusCode");
    return false;
  }
}

Future<bool> editActivity(String name, int activityId, String tagList) async {
  var uri =
  Uri.parse("$baseUrl/editActivity?$name&$activityId&$tagList");
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    Map<String, dynamic> decoded = convert.jsonDecode(response.body);
    return decoded['added'];
  } else {
    print("statusCode=$response.statusCode");
    return false;
  }
}

Future<ActivityList> retrieveActivityList(String tagToSearch) async {
  var uri =
  Uri.parse("$baseUrl/searchByTag?$tagToSearch");
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    List<dynamic> decoded = convert.jsonDecode(response.body);
    print(decoded.toString());
    return ActivityList(decoded);
  } else {
    print("statusCode=$response.statusCode");
    throw Exception("Connection error");
  }
}

Future<ActivityList> retrieveActivityListChilds(String tagToSearch,int id) async {
  var uri =
  Uri.parse("$baseUrl/searchByTagChilds?$tagToSearch&$id");
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    List<dynamic> decoded = convert.jsonDecode(response.body);
    print(decoded.toString());
    return ActivityList(decoded);
  } else {
    print("statusCode=$response.statusCode");
    throw Exception("Connection error");
  }
}

Future<ActivityList> retrieveRecentActivityList(List<int> list) async {
  String urlToParse;
  urlToParse = "$baseUrl/getActivitys?";
  for(int i=0; i<list.length; i++){
    String idString = list[i].toString();
    if(i!=list.length-1){
      idString=idString+"&";
    }
    urlToParse= urlToParse+idString;
  }
  var uri =
  Uri.parse(urlToParse);
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    List<dynamic> decoded = convert.jsonDecode(response.body);
    print(decoded.toString());
    return ActivityList(decoded);
  } else {
    print("statusCode=$response.statusCode");
    throw Exception("Connection error");
  }
}
