import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Report'),
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text("Period "),
                    ),
                    DropdownButton(
                      value: _periodSelected,
                      items: periodItems.map((String periodItems) {
                        return DropdownMenuItem(
                            value: periodItems,
                            child: Text(periodItems)
                        );
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text("From "),
                    ),
                    Text("2021-11-11"),
                    Icon(Icons.calendar_today)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text("To "),
                    ),
                    Text("2021-11-13"),
                    Icon(Icons.calendar_today)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
              ],
            ),
          ),
        ));
  }
}
