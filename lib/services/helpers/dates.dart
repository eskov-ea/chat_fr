import 'package:chat/services/global.dart';
import 'package:intl/intl.dart';



String dateFormater(DateTime rawDate) {
  final now = DateTime.now();
  final lastMidnight = DateTime(now.year, now.month,  now.day);
  final dayBeforeYesterday = DateTime(now.year, now.month,  now.day).subtract(const Duration(days: 1));
  final lastMonday = DateTime(now.year, now.month,  now.day - (now.weekday - 1));
  final hoursSinceMessageWritten = (now.millisecondsSinceEpoch - rawDate.millisecondsSinceEpoch) / 1000/60/60;
  final hoursSinceLastMidnight = (now.add(getTZ()).millisecondsSinceEpoch - lastMidnight.millisecondsSinceEpoch) / 1000/60/60;
  final hoursSinceDayBeforeYesterday = (now.millisecondsSinceEpoch - dayBeforeYesterday.millisecondsSinceEpoch) / 1000/60/60;
  final hoursSinceLastMonday = (now.millisecondsSinceEpoch - lastMonday.millisecondsSinceEpoch) / 1000/60/60;

  ///check if message was written in 2 minutes
  if (hoursSinceMessageWritten < 0.035) {
    return "Только что";
  } else {
    ///check if message was written in this day range
    if (hoursSinceMessageWritten <= hoursSinceLastMidnight) {
      return DateFormat.Hm().format(rawDate.add(getTZ()));
      ///check if message was written yesterday
    } else if (hoursSinceMessageWritten > hoursSinceLastMidnight && hoursSinceMessageWritten <= hoursSinceDayBeforeYesterday) {
      return "Вчера";
      ///check if message was written in range of this week
    } else if (hoursSinceMessageWritten > hoursSinceDayBeforeYesterday && hoursSinceMessageWritten <= hoursSinceLastMonday) {
      return _toRussianWeekday(rawDate.weekday);
    } else {
      final date = DateFormat.yMd().format(rawDate).replaceAll(RegExp('/'), '.');
      final splittedDate = date.split('.');
      final tmp = splittedDate[1];
      splittedDate[1] = splittedDate[0];
      splittedDate[0] = tmp;
      for (var i = 0; i < splittedDate.length; i++) {
        if (int.parse(splittedDate[i]) <= 9 ) {
          splittedDate[i] = "0${splittedDate[i]}";
        }
      }
      return splittedDate.join(".");
    }
  }
}

String _toRussianWeekday (int day) {
  switch(day) {
    case 1: return "Воскресенье";
    case 2: return "Понедельник";
    case 3: return "Вторник";
    case 4: return "Среда";
    case 5: return "Четверг";
    case 6: return "Пятница";
    case 7: return "Суббота";
    default: return day.toString();

  }
}