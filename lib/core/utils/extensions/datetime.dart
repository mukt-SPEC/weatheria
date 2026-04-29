import 'package:intl/intl.dart';

extension FormatDateTime on DateTime {
  String get dateTime => DateFormat("yMMMMd").format(this);

  String get time => DateFormat("HH:mm").format(this);
}

extension DayOfWeek on DateTime {
  String get dayofweek => DateFormat("EEEE").format(this);
}
