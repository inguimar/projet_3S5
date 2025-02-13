import 'package:isar/isar.dart';

@embedded
class Schedule {
  DateTime openAt;
  DateTime closeAt;

  Schedule({required this.openAt,required this.closeAt});
}

@embedded
class DailySchedule{
  List<Schedule> schedules;

  DailySchedule({required this.schedules});
}

@embedded
class WeeklySchedule {
  List<DailySchedule> dailySchedules;

  WeeklySchedule({required this.dailySchedules});
}