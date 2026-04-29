import 'package:intl/intl.dart';

extension ConvertTimeStampToTime on int {
  String get toTime =>
      DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(this * 1000));

  String get toDateTime =>
      DateFormat("yMMMMd").format(DateTime.fromMillisecondsSinceEpoch(this * 1000));
}