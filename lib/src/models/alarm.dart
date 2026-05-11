class Alarm {
  final int alarmId;
  final String type;
  final String title;
  final String regNo;
  final String message;
  final String timeAgo;
  final String receivedFmt;
  final String iconStatus;
  final String iconImage;

  Alarm({
    required this.alarmId,
    required this.type,
    required this.title,
    required this.regNo,
    required this.message,
    required this.timeAgo,
    required this.receivedFmt,
    required this.iconStatus,
    required this.iconImage,
  });

  factory Alarm.fromJson(Map<String, dynamic> j) => Alarm(
        alarmId:     (j['alarm_id'] as num).toInt(),
        type:        (j['type']     ?? '').toString(),
        title:       (j['title']    ?? '').toString(),
        regNo:       (j['reg_no']   ?? '').toString(),
        message:     (j['message']  ?? '').toString(),
        timeAgo:     (j['time_ago'] ?? '').toString(),
        receivedFmt: (j['received_fmt'] ?? '').toString(),
        iconStatus:  (j['icon_status']  ?? '').toString(),
        iconImage:   (j['icon_image']   ?? '').toString(),
      );
}

class AlarmsResponse {
  final int total;
  final int page;
  final int perPage;
  final List<Alarm> alarms;
  AlarmsResponse({
    required this.total,
    required this.page,
    required this.perPage,
    required this.alarms,
  });
  factory AlarmsResponse.fromJson(Map<String, dynamic> j) => AlarmsResponse(
        total:   (j['total']    as num?)?.toInt() ?? 0,
        page:    (j['page']     as num?)?.toInt() ?? 1,
        perPage: (j['per_page'] as num?)?.toInt() ?? 50,
        alarms:  ((j['alarms']  as List?) ?? const [])
            .map((e) => Alarm.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
