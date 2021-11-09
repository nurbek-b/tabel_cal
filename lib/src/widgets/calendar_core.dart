// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:table_calendar/src/extansions/extansions.dart';
import 'package:table_calendar/src/widgets/calendar_list_view.dart';
import 'package:table_calendar/src/widgets/date_models.dart';

import '../shared/utils.dart';
import 'calendar_page.dart';

typedef _OnCalendarPageChanged = void Function(
    int pageIndex, DateTime focusedDay);

class CalendarCore extends StatefulWidget {
  final DateTime? focusedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final CalendarFormat calendarFormat;
  final DayBuilder? dowBuilder;
  final FocusedDayBuilder dayBuilder;
  final bool sixWeekMonthsEnforced;
  final bool dowVisible;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final double? dowHeight;
  final double? rowHeight;
  final BoxConstraints constraints;
  final int? previousIndex;
  final StartingDayOfWeek startingDayOfWeek;
  final PageController? pageController;
  final ScrollPhysics? scrollPhysics;
  final _OnCalendarPageChanged onPageChanged;
  final Axis scrollDirection;

  const CalendarCore({
    Key? key,
    this.dowBuilder,
    required this.dayBuilder,
    required this.onPageChanged,
    required this.firstDay,
    required this.lastDay,
    required this.constraints,
    this.dowHeight,
    this.rowHeight,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.calendarFormat = CalendarFormat.month,
    this.pageController,
    this.focusedDay,
    this.previousIndex,
    this.sixWeekMonthsEnforced = false,
    this.dowVisible = true,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.scrollPhysics,
    this.scrollDirection = Axis.vertical,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        super(key: key);

  @override
  State<CalendarCore> createState() => _CalendarCoreState();
}

class _CalendarCoreState extends State<CalendarCore> {
  late DateTime _minDate;
  late DateTime _maxDate;
  late List<Month> _months;
  late DateTime rangeMinDate;
  late DateTime rangeMaxDate;

  @override
  void initState() {
    super.initState();
    _months = CustomDateUtils.extractWeeks(widget.firstDay, widget.lastDay);
    _minDate = widget.firstDay.removeTime();
    _maxDate = widget.lastDay.removeTime();
    // rangeMinDate = widget.initialMinDate;
    // rangeMaxDate = widget.initialMaxDate;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scrollDirection == Axis.horizontal) {
      return PageView.builder(
        controller: widget.pageController,
        physics: widget.scrollPhysics,
        itemCount: _getPageCount(
            widget.calendarFormat, widget.firstDay, widget.lastDay),
        itemBuilder: (context, index) {
          final baseDay = _getBaseDay(widget.calendarFormat, index);
          final visibleRange = _getVisibleRange(widget.calendarFormat, baseDay);
          final visibleDays =
              _daysInRange(visibleRange.start, visibleRange.end);

          final actualDowHeight = widget.dowVisible ? widget.dowHeight! : 0.0;
          final constrainedRowHeight = widget.constraints.hasBoundedHeight
              ? (widget.constraints.maxHeight - actualDowHeight) /
                  _getRowCount(widget.calendarFormat, baseDay)
              : null;

          return CalendarPage(
            visibleDays: visibleDays,
            dowVisible: widget.dowVisible,
            dowDecoration: widget.dowDecoration,
            rowDecoration: widget.rowDecoration,
            tableBorder: widget.tableBorder,
            dowBuilder: (context, day) {
              return SizedBox(
                height: widget.dowHeight,
                child: widget.dowBuilder?.call(context, day),
              );
            },
            dayBuilder: (context, day) {
              DateTime baseDay;
              final previousFocusedDay = widget.focusedDay;
              if (previousFocusedDay == null || widget.previousIndex == null) {
                baseDay = _getBaseDay(widget.calendarFormat, index);
              } else {
                baseDay = _getFocusedDay(
                    widget.calendarFormat, previousFocusedDay, index);
              }

              return SizedBox(
                height: constrainedRowHeight ?? widget.rowHeight,
                child: widget.dayBuilder(context, day, baseDay),
              );
            },
          );
        },
        onPageChanged: (index) {
          DateTime baseDay;
          final previousFocusedDay = widget.focusedDay;
          if (previousFocusedDay == null || widget.previousIndex == null) {
            baseDay = _getBaseDay(widget.calendarFormat, index);
          } else {
            baseDay = _getFocusedDay(
                widget.calendarFormat, previousFocusedDay, index);
          }

          return widget.onPageChanged(index, baseDay);
        },
      );
    } else {
      return Column(
        children: [
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('S', style: TextStyle(fontSize: 10)),
                Text('M', style: TextStyle(fontSize: 10)),
                Text('T', style: TextStyle(fontSize: 10)),
                Text('W', style: TextStyle(fontSize: 10)),
                Text('T', style: TextStyle(fontSize: 10)),
                Text('F', style: TextStyle(fontSize: 10)),
                Text('S', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
          Divider(),
          Flexible(
            child: ListView.builder(
                cacheExtent:
                    (MediaQuery.of(context).size.width / DateTime.daysPerWeek) *
                        6,
                controller: widget.pageController,
                itemCount: _months.length,
                itemBuilder: (BuildContext context, int position) {
                  final baseDay = _getBaseDay(widget.calendarFormat, position);
                  final visibleRange =
                      _getVisibleRange(widget.calendarFormat, baseDay);
                  final visibleDays =
                      _daysInRange(visibleRange.start, visibleRange.end);
                  final actualDowHeight =
                      widget.dowVisible ? widget.dowHeight! : 0.0;
                  final constrainedRowHeight =
                      widget.constraints.hasBoundedHeight
                          ? (widget.constraints.maxHeight - actualDowHeight) /
                              _getRowCount(widget.calendarFormat, baseDay)
                          : null;

                  return VerticalMonthView(
                    month: _months[position],
                    minDate: _minDate,
                    maxDate: _maxDate,
                    visibleDays: visibleDays,
                    dowBuilder: (context, day) {
                      return SizedBox(
                        height: widget.dowHeight,
                        child: widget.dowBuilder?.call(context, day),
                      );
                    },
                    dayBuilder: (context, day) {
                      print('$day tapped on calendar core');
                      DateTime baseDay;
                      final previousFocusedDay = widget.focusedDay;
                      if (previousFocusedDay == null ||
                          widget.previousIndex == null) {
                        baseDay = _getBaseDay(widget.calendarFormat, position);
                      } else {
                        baseDay = _getFocusedDay(widget.calendarFormat,
                            previousFocusedDay, position);
                      }

                      return SizedBox(
                        height: constrainedRowHeight ?? widget.rowHeight,
                        child: widget.dayBuilder(context, day, baseDay),
                      );
                    },
                  );
                }),
          ),
        ],
      );
    }
  }

  int _getPageCount(CalendarFormat format, DateTime first, DateTime last) {
    switch (format) {
      case CalendarFormat.month:
        return _getMonthCount(first, last) + 1;
      case CalendarFormat.twoWeeks:
        return _getTwoWeekCount(first, last) + 1;
      case CalendarFormat.week:
        return _getWeekCount(first, last) + 1;
      default:
        return _getMonthCount(first, last) + 1;
    }
  }

  int _getMonthCount(DateTime first, DateTime last) {
    final yearDif = last.year - first.year;
    final monthDif = last.month - first.month;

    return yearDif * 12 + monthDif;
  }

  int _getWeekCount(DateTime first, DateTime last) {
    return last.difference(_firstDayOfWeek(first)).inDays ~/ 7;
  }

  int _getTwoWeekCount(DateTime first, DateTime last) {
    return last.difference(_firstDayOfWeek(first)).inDays ~/ 14;
  }

  DateTime _getFocusedDay(
      CalendarFormat format, DateTime prevFocusedDay, int pageIndex) {
    if (pageIndex == widget.previousIndex) {
      return prevFocusedDay;
    }

    final pageDif = pageIndex - widget.previousIndex!;
    DateTime day;

    switch (format) {
      case CalendarFormat.month:
        day = DateTime.utc(prevFocusedDay.year, prevFocusedDay.month + pageDif);
        break;
      case CalendarFormat.twoWeeks:
        day = DateTime.utc(prevFocusedDay.year, prevFocusedDay.month,
            prevFocusedDay.day + pageDif * 14);
        break;
      case CalendarFormat.week:
        day = DateTime.utc(prevFocusedDay.year, prevFocusedDay.month,
            prevFocusedDay.day + pageDif * 7);
        break;
    }

    if (day.isBefore(widget.firstDay)) {
      day = widget.firstDay;
    } else if (day.isAfter(widget.lastDay)) {
      day = widget.lastDay;
    }

    return day;
  }

  DateTime _getBaseDay(CalendarFormat format, int pageIndex) {
    DateTime day;

    switch (format) {
      case CalendarFormat.month:
        day = DateTime.utc(
            widget.firstDay.year, widget.firstDay.month + pageIndex);
        break;
      case CalendarFormat.twoWeeks:
        day = DateTime.utc(widget.firstDay.year, widget.firstDay.month,
            widget.firstDay.day + pageIndex * 14);
        break;
      case CalendarFormat.week:
        day = DateTime.utc(widget.firstDay.year, widget.firstDay.month,
            widget.firstDay.day + pageIndex * 7);
        break;
    }

    if (day.isBefore(widget.firstDay)) {
      day = widget.firstDay;
    } else if (day.isAfter(widget.lastDay)) {
      day = widget.lastDay;
    }

    return day;
  }

  DateTimeRange _getVisibleRange(CalendarFormat format, DateTime focusedDay) {
    print('focused day is $focusedDay');
    switch (format) {
      case CalendarFormat.month:
        return _daysInMonth(focusedDay);
      case CalendarFormat.twoWeeks:
        return _daysInTwoWeeks(focusedDay);
      case CalendarFormat.week:
        return _daysInWeek(focusedDay);
      default:
        return _daysInMonth(focusedDay);
    }
  }

  DateTimeRange _daysInWeek(DateTime focusedDay) {
    final daysBefore = _getDaysBefore(focusedDay);
    final firstToDisplay = focusedDay.subtract(Duration(days: daysBefore));
    final lastToDisplay = firstToDisplay.add(const Duration(days: 7));
    return DateTimeRange(start: firstToDisplay, end: lastToDisplay);
  }

  DateTimeRange _daysInTwoWeeks(DateTime focusedDay) {
    final daysBefore = _getDaysBefore(focusedDay);
    final firstToDisplay = focusedDay.subtract(Duration(days: daysBefore));
    final lastToDisplay = firstToDisplay.add(const Duration(days: 14));
    return DateTimeRange(start: firstToDisplay, end: lastToDisplay);
  }

  DateTimeRange _daysInMonth(DateTime focusedDay) {
    final first = _firstDayOfMonth(focusedDay);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    if (widget.sixWeekMonthsEnforced) {
      final end = firstToDisplay.add(const Duration(days: 42));
      return DateTimeRange(start: firstToDisplay, end: end);
    }

    final last = _lastDayOfMonth(focusedDay);
    final daysAfter = _getDaysAfter(last);
    final lastToDisplay = last.add(Duration(days: daysAfter));

    return DateTimeRange(start: firstToDisplay, end: lastToDisplay);
  }

  List<DateTime> _daysInRange(DateTime first, DateTime last) {
    final dayCount = last.difference(first).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(first.year, first.month, first.day + index),
    );
  }

  DateTime _firstDayOfWeek(DateTime week) {
    final daysBefore = _getDaysBefore(week);
    return week.subtract(Duration(days: daysBefore));
  }

  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1);
  }

  DateTime _lastDayOfMonth(DateTime month) {
    final date = month.month < 12
        ? DateTime.utc(month.year, month.month + 1, 1)
        : DateTime.utc(month.year + 1, 1, 1);
    return date.subtract(const Duration(days: 1));
  }

  int _getRowCount(CalendarFormat format, DateTime focusedDay) {
    if (format == CalendarFormat.twoWeeks) {
      return 2;
    } else if (format == CalendarFormat.week) {
      return 1;
    } else if (widget.sixWeekMonthsEnforced) {
      return 6;
    }

    final first = _firstDayOfMonth(focusedDay);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    final last = _lastDayOfMonth(focusedDay);
    final daysAfter = _getDaysAfter(last);
    final lastToDisplay = last.add(Duration(days: daysAfter));

    return (lastToDisplay.difference(firstToDisplay).inDays + 1) ~/ 7;
  }

  int _getDaysBefore(DateTime firstDay) {
    return (firstDay.weekday + 7 - getWeekdayNumber(widget.startingDayOfWeek)) %
        7;
  }

  int _getDaysAfter(DateTime lastDay) {
    int invertedStartingWeekday =
        8 - getWeekdayNumber(widget.startingDayOfWeek);

    int daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7);
    if (daysAfter == 7) {
      daysAfter = 0;
    }

    return daysAfter;
  }
}
