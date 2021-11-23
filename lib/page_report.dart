import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PageReport extends StatefulWidget {
  const PageReport({Key? key}) : super(key: key);

  @override
  _PageReportState createState() => _PageReportState();
}

DateTime _today = DateTime.now();

class _PageReportState extends State<PageReport> {
  var periodItems = ["Last week", "This week", "Yesterday", "Today", "Other"];
  var contentItems = ["Brief", "Detailed", "Statistic"];
  var formatItems = ["WebPage", "PDF", "Text"];

  late String _periodSelected;
  late String _formatSelected;
  late String _contentSelected;
  late DateTimeRange _dateRange;
  late DateFormat _dateFormat;

  @override
  void initState() {
    _dateFormat = DateFormat("yyyy-MM-dd");
    _dateRange = DateTimeRange(start: _today, end: _today);
    _contentSelected = contentItems[0];
    _formatSelected = formatItems[0];
    _periodSelected = periodItems[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Report'),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: const Text("Period"),
                    width: 100,
                    margin: const EdgeInsets.only(left: 80),
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
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: const Text("From"),
                    width: 100,
                    margin: const EdgeInsets.only(left: 80),
                  ),
                  Text(_dateFormat.format(_dateRange.start)),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    highlightColor: Colors.cyan,
                    color: Colors.cyan,
                    onPressed: () {
                      _pickFromDate();
                    },
                  )
                ],
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: const Text("To"),
                    width: 100,
                    margin: const EdgeInsets.only(left: 80),
                  ),
                  Text(_dateFormat.format(_dateRange.end)),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    highlightColor: Colors.cyan,
                    color: Colors.cyan,
                    onPressed: () {
                      _pickToDate();
                    },
                  )
                ],
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: const Text("Content"),
                    width: 100,
                    margin: const EdgeInsets.only(left: 80),
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
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: const Text("Format"),
                    width: 100,
                    margin: const EdgeInsets.only(left: 80),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  _pickFromDate() async {
    DateTime? newStart = await showDatePicker(
      context: context,
      firstDate: DateTime(_today.year - 5),
      lastDate: DateTime(_today.year + 5),
      initialDate: _dateRange.start,
    );
    DateTime end = _dateRange.end; // the present To date
    if (end.difference(newStart!) >= const Duration(days: 0)) {
      _dateRange = DateTimeRange(start: newStart, end: end);
      setState(() {
        _periodSelected = 'Other'; // to redraw the screen
      });
    } else {
      _showAlertDates();
    }
  }

  _pickToDate() async {
    DateTime? newEnd = await showDatePicker(
      context: context,
      firstDate: DateTime(_today.year - 5),
      lastDate: DateTime(_today.year + 5),
      initialDate: _dateRange.end,
    );
    DateTime start =_dateRange.start; // the present To date
    if (newEnd!.difference(start) >= const Duration(days: 0)) {
      _dateRange = DateTimeRange(start: start, end: newEnd);
      setState(() {
        _periodSelected = 'Other'; // to redraw the screen
      });
    } else {
      _showAlertDates();
    }
  }

  void _showAlertDates() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Range Dates"),
              content: const Text(
                  "The From date is after the To Date.\n\n Please, select a new date."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text(
                      "ACCEPT",
                      style: TextStyle(fontSize: 25),
                    ))
              ],
            ));
  }
}
