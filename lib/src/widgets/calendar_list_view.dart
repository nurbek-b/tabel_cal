import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/src/extansions/extansions.dart';
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
  final ValueChanged<DateTime>? onDayPressed;
  final bool dowVisible;
  final List<DateTime> visibleDays;
  final DateTime? rangeMinDate;
  final DateTime? rangeMaxDate;

  VerticalMonthView({
    required this.month,
    required this.minDate,
    required this.maxDate,
    required this.dayBuilder,
    required this.visibleDays,
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
            : _DefaultMonthView(month: month.month, year: month.year),
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
    bool rangeFeatureEnabled = rangeMinDate != null;

    return TableRow(
        children: List<Widget>.generate(DateTime.daysPerWeek, (int position) {
      DateTime day = DateTime(week.firstDay.year, week.firstDay.month,
          firstDay.day + (position - (firstDay.weekday - 1)));

      if ((position + 1) < week.firstDay.weekday ||
          (position + 1) > week.lastDay.weekday ||
          day.isBefore(minDate) ||
          day.isAfter(maxDate)) {
        return const SizedBox();
      } else {
        bool isSelected = false;

        if (rangeFeatureEnabled) {
          if (rangeMinDate != null && rangeMaxDate != null) {
            isSelected = day.isSameDayOrAfter(rangeMinDate!) &&
                day.isSameDayOrBefore(rangeMaxDate!);
          } else {
            isSelected = day.isAtSameMomentAs(rangeMinDate!);
          }
        }

        return AspectRatio(
          aspectRatio: 1.0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDayPressed != null
                ? () {
                    if (onDayPressed != null) {
                      onDayPressed!(day);
                    }
                  }
                : null,
            child: _DefaultDayView(date: day, isSelected: isSelected),
          ),
        );
      }
    }, growable: false));
  }
}

class _DefaultMonthView extends StatelessWidget {
  final int month;
  final int year;

  _DefaultMonthView({required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        DateFormat('MMMM').format(DateTime(year, month)),
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}

class _DefaultDayView extends StatelessWidget {
  final DateTime date;
  final bool isSelected;

  _DefaultDayView({required this.date, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
          color: isSelected == true ? Colors.red : Colors.transparent,
          shape: BoxShape.circle),
      child: Center(
        child: Text(
          DateFormat('d').format(date),
        ),
      ),
    );
  }
}

typedef MonthBuilder = Widget Function(
    BuildContext context, int month, int year);
typedef PeriodChanged = void Function(DateTime minDate, DateTime maxDate);
