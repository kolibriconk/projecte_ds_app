import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PageReport extends StatefulWidget {
  const PageReport({Key? key}) : super(key: key);

  @override
  _PageReportState createState() => _PageReportState();
}

class _PageReportState extends State<PageReport> {
  String _periodSelected = "Last week";
  var periodItems = ["Last week", "This week", "Yesterday", "Today", "Other"];

  String _contentSelected = "Brief";
  var contentItems = ["Brief", "Detailed", "Statistic"];

  String _formatSelected = "WebPage";
  var formatItems = ["WebPage", "PDF", "Text"];

  String _fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

  String _toDate = DateFormat("yyyy-MM-dd").format(DateTime.now().add(const Duration(days: 1)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Report'),
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: const Text("Period "),
                    ),
                    DropdownButton(
                      value: _periodSelected,
                      items: periodItems.map((String periodItems) {
                        return DropdownMenuItem(
                            value: periodItems, child: Text(periodItems));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _periodSelected = newValue!;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: const Text("From "),
                    ),
                    Container(
                      child: Row(children: [
                        Text(_fromDate),
                        const Text("  "),
                        IconButton(
                          icon: Icon(Icons.calendar_today_outlined),
                          highlightColor: Colors.cyan,
                          color: Colors.cyan,
                          onPressed: () {},
                        )
                      ]),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Text("To "),
                    ),
                    Container(
                      child: Row(children: [
                        Text(_toDate),
                        const Text("  "),
                        IconButton(
                          icon: Icon(Icons.calendar_today_outlined),
                          highlightColor: Colors.cyan,
                          color: Colors.cyan,
                          onPressed: () {},
                        )
                      ]),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Text("Content "),
                    ),
                    DropdownButton(
                      value: _contentSelected,
                      items: contentItems.map((String contentItems) {
                        return DropdownMenuItem(
                            value: contentItems, child: Text(contentItems));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _contentSelected = newValue!;
                        });
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Text("Format "),
                    ),
                    DropdownButton(
                      value: _formatSelected,
                      items: formatItems.map((String formatItems) {
                        return DropdownMenuItem(
                            value: formatItems, child: Text(formatItems));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _formatSelected = newValue!;
                        });
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        child: TextButton(
                      child: const Text("Generate",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {},
                    )),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
