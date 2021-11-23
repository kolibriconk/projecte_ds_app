import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PageReport extends StatefulWidget {
  const PageReport({Key? key}) : super(key: key);

  @override
  _PageReportState createState() => _PageReportState();
}

DateTime _today = DateTime.now();

class _PageReportState extends State<PageReport> {
  static const String lastWeekPeriod = "Last week";
  static const String thisWeekPeriod = "This week";
  static const String yesterdayPeriod = "Yesterday";
  static const String todayPeriod = "Today";
  static const String otherPeriod = "Other";
  var periodItems = [lastWeekPeriod, thisWeekPeriod, yesterdayPeriod, todayPeriod, otherPeriod];

  static const String briefContent = "Brief";
  static const String detailedContent = "Detailed";
  static const String statisticContent = "Statistic";
  var contentItems = [briefContent, detailedContent, statisticContent];

  static const String webPageContent = "WebPage";
  static const String pdfContent = "PDF";
  static const String textContent = "Text";
  var formatItems = [webPageContent, pdfContent, textContent];

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
                    onChanged: (String? newValue) =>
                        _setDatesAccording(newValue),
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
    DateTime start = _dateRange.start; // the present To date
    if (newEnd!.difference(start) >= const Duration(days: 0)) {
      _dateRange = DateTimeRange(start: start, end: newEnd);
      setState(() {
        _periodSelected = otherPeriod; // to redraw the screen
      });
    } else {
      _showAlertDates();
    }
  }

  _showAlertDates() {
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

  _setDatesAccording(String? newValue) {
    DateTime yesterday = _today.subtract(const Duration(days:1));
    DateTime mondayThisWeek = DateTime(_today.year, _today.month,
        _today.day - _today.weekday + 1);
    DateTime sundayLastWeek = mondayThisWeek.subtract(const Duration(days:1));
    DateTime mondayLastWeek = mondayThisWeek.subtract(const Duration(days:7));

    //Setting default values
    DateTime newStart = mondayLastWeek;
    DateTime newEnd = sundayLastWeek;
    String periodSelected = lastWeekPeriod;

    switch(newValue){
      case thisWeekPeriod:
        newStart = mondayThisWeek;
        newEnd = _today;
        periodSelected = thisWeekPeriod;
        break;

      case yesterdayPeriod:
        newStart = yesterday;
        newEnd = yesterday;
        periodSelected = yesterdayPeriod;
        break;

      case todayPeriod:
        newStart = _today;
        newEnd = _today;
        periodSelected = todayPeriod;
        break;

      case otherPeriod:
        periodSelected = otherPeriod;
        break;

      case lastWeekPeriod:
      default:
    }

    //Updating values
    setState(() {
      _periodSelected = periodSelected;
      _dateRange = DateTimeRange(start: newStart, end: newEnd);
    });
  }
}
