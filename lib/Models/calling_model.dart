class CallingModel {
  final String callId;
  final String callType;
  final List receptientsId;
  final String dateTime;
  final String callState;
  final int callDuration;

  CallingModel(
      {required this.callId,
      required this.callType,
      required this.receptientsId,
      required this.dateTime,
      required this.callState,
      required this.callDuration});
  factory CallingModel.fromJson(Map<String, dynamic> map, String id) {
    return CallingModel(
        callId: id,
        callType: map['callType'],
        receptientsId: map['receptientsId'],
        dateTime: map['dateTime'],
        callState: map['callState'],
        callDuration: map['callDuration']);
  }
}
