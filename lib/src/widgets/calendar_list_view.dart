import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/src/widgets/date_models.dart';

class VerticalMonthView extends StatelessWidget {
  final Widget Function(BuildContext context, DateTime day)? dowBuilder;
  final Widget Function(BuildContext context, DateTime day) dayBuilder;
  final Month month;
  final DateTime minDate;
  final DateTime maxDate;
  final MonthBuilder? monthBuilder;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final TextStyle monthTextStyle;
  final ValueChanged<DateTime>? onDayPressed;
  final bool dowVisible;
  final List<DateTime> visibleDays;
  final DateTime? rangeMinDate;
  final DateTime? rangeMaxDate;
  final double cellHeight;

  VerticalMonthView({
    required this.month,
    required this.minDate,
    required this.maxDate,
    required this.dayBuilder,
    required this.visibleDays,
    required this.cellHeight,
    this.monthTextStyle = const TextStyle(),
    this.dowDecoration,
    this.rowDecoration,
    this.dowBuilder,
    this.monthBuilder,
    this.onDayPressed,
    this.tableBorder,
    this.rangeMinDate,
    this.rangeMaxDate,
    this.dowVisible = true,
    Key? key,
  })  : assert(!dowVisible || dowBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        monthBuilder != null
            ? monthBuilder!(context, month.month, month.year)
            : _DefaultMonthView(
                month: month.month,
                year: month.year,
                monthTextStyle: monthTextStyle),
        Table(
          children: month.weeks
              .map((Week week) => _generateFor(context, week))
              .toList(growable: false),
        ),
      ],
    );
  }

  TableRow _generateFor(BuildContext context, Week week) {
    DateTime firstDay = week.firstDay;

    return TableRow(
      children: List<Widget>.generate(DateTime.daysPerWeek, (int position) {
        DateTime day = DateTime(
          week.firstDay.year,
          week.firstDay.month,
          firstDay.day + (position - (firstDay.weekday - 1)),
        );

        if ((position + 1) < week.firstDay.weekday ||
            (position + 1) > week.lastDay.weekday ||
            day.isBefore(minDate) ||
            day.isAfter(maxDate)) {
          return const SizedBox();
        } else {
          return SizedBox(height: cellHeight, child: dayBuilder(context, day));
        }
      }, growable: false),
    );
  }
}

class _DefaultMonthView extends StatelessWidget {
  final int month;
  final int year;
  final TextStyle monthTextStyle;

  _DefaultMonthView({
    required this.month,
    required this.year,
    this.monthTextStyle = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        DateFormat('MMMM yyyy').format(DateTime(year, month)),
        style: monthTextStyle,
      ),
    );
  }
}

typedef MonthBuilder = Widget Function(
    BuildContext context, int month, int year);
typedef PeriodChanged = void Function(DateTime minDate, DateTime maxDate);
