// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class DateData {
  final String title;
  final bool periodDays;
  final bool fertilityWindow;
  final bool ovulationDay;
  final bool symptomsAdded;
  final bool sex;

  const DateData(this.title,
      {this.periodDays = false,
      this.fertilityWindow = false,
      this.ovulationDay = false,
      this.symptomsAdded = false,
      this.sex = false});

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final dateData = LinkedHashMap<DateTime, List<DateData>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_dateDataSource);

final _dateDataSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(item % 4 + 1,
        (index) => DateData('Data $item | ${index + 1}', symptomsAdded: true)))
  ..addAll({
    kToday: [
      DateData('Today\'s Data 1', sex: true),
      DateData('Today\'s Data 2', symptomsAdded: true),
    ],
    kToday.subtract(Duration(days: 1)): [
      DateData('Today\'s Data 1', sex: true),
      DateData('Today\'s Data 2', symptomsAdded: true),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 5;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 1, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year + 1, kToday.month, kToday.day);
