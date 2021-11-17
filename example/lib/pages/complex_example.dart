import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';

class TableComplexExample extends StatefulWidget {
  @override
  _TableComplexExampleState createState() => _TableComplexExampleState();
}

class _TableComplexExampleState extends State<TableComplexExample> {
  late final PageController _pageController;
  late final ValueNotifier<List<DateData>> _selectedDaysData;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late DateTime today;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    _selectedDays.add(_focusedDay.value);
    _selectedDaysData = ValueNotifier(_getDataForDay(_focusedDay.value));
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedDaysData.dispose();
    super.dispose();
  }

  bool get canClearSelection =>
      _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  List<DateData> _getDataForDay(DateTime day) {
    return dateData[day] ?? [];
  }

  List<DateData> _getDataForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getDataForDay(d),
    ];
  }

  List<DateData> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getDataForDays(days);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print('tapped to select day');
    setState(() {
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }
      _focusedDay.value = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    _selectedDaysData.value = _getDataForDays(_selectedDays);
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _selectedDays.clear();
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedDaysData.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedDaysData.value = _getDataForDay(start);
    } else if (end != null) {
      _selectedDaysData.value = _getDataForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar - Complex'),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 24, left: 12, right: 12),
        child: TableCalendar<DateData>(
          firstDay: DateTime(today.year - 2, today.month, today.day),
          lastDay: DateTime(today.year + 2, today.month, today.day),
          focusedDay: _focusedDay.value,
          headerVisible: false,
          selectedDayPredicate: (day) => _selectedDays.contains(day),
          scrollDirection: Axis.vertical,
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          dayDataLoader: _getDataForDay,
          onDaySelected: _onDaySelected,
          onRangeSelected: _onRangeSelected,
          onCalendarCreated: (controller) => _pageController = controller,
          onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() => _calendarFormat = format);
            }
          },
          calendarStyle: CalendarStyle(
            isTodayHighlighted: true,
            todayTextStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            selectedDecoration: const BoxDecoration(color: Colors.transparent),
            rangeHighlightScale: 0.0,
            selectedTextStyle: TextStyle(color: Color(0xffFF9494)),
            rangeStartTextStyle: TextStyle(color: Color(0xffFF9494)),
            rangeEndTextStyle: TextStyle(color: Color(0xffFF9494)),
            withinRangeTextStyle: TextStyle(color: Color(0xffFF9494)),
            fertilityTextStyle: TextStyle(color: Color(0xffFCB54C)),
            periodDaysTextStyle: TextStyle(color: Color(0xffFF9494)),
            rangeStartDecoration:
                const BoxDecoration(color: Colors.transparent),
            rangeEndDecoration: const BoxDecoration(color: Colors.transparent),
          ),
          calendarBuilders: CalendarBuilders(
          
            singleMarkerBuilder: (context, date, data) {
              final children = <Widget>[];
              if (data.periodDays) if (!children
                  .contains(Text('.', style: TextStyle(color: Colors.black)))) {
                children.add(
                  Text('.', style: TextStyle(color: Colors.black)),
                );
              }

              if (data.sex) if (!children
                  .contains(Text(',', style: TextStyle(color: Colors.black)))) {
                children.add(
                  Text(',', style: TextStyle(color: Colors.black)),
                );
              }

              if (data.symptomsAdded) if (!children
                  .contains(Text('_', style: TextStyle(color: Colors.black)))) {
                children.add(
                  Text('_', style: TextStyle(color: Colors.black)),
                );
              }

              if (data.ovulationDay) if (!children
                  .contains(Text('=', style: TextStyle(color: Colors.black)))) {
                children.add(
                  Text('=', style: TextStyle(color: Colors.black)),
                );
              }

              return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children.toSet().toList());
            },
          ),
        ),
      ),
    );
  }
}
