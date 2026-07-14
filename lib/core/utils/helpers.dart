import 'package:intl/intl.dart';

class Helpers {
  static DateTime toIst(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final ist = utc.add(const Duration(hours: 5, minutes: 30));
    return DateTime(ist.year, ist.month, ist.day, ist.hour, ist.minute, ist.second, ist.millisecond);
  }

  static String formatIst(DateTime dateTime, String pattern) {
    return DateFormat(pattern).format(toIst(dateTime));
  }
}
