class CallHistoryModel {
  final String id;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final String callType;
  final String status;
  final DateTime timestamp;
  final int duration;

  CallHistoryModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.callType,
    required this.status,
    required this.timestamp,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'callType': callType,
      'status': status,
      'timestamp': timestamp,
      'duration': duration,
    };
  }

  factory CallHistoryModel.fromMap(Map<String, dynamic> map) {
    return CallHistoryModel(
      id: map['id'] ?? '',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      callType: map['callType'] ?? 'audio',
      status: map['status'] ?? 'completed',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'].toDate().toString())
          : DateTime.now(),
      duration: map['duration'] ?? 0,
    );
  }
}