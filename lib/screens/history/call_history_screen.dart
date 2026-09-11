import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/call_history_model.dart';
import '../../services/call_history_service.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() =>
      _CallHistoryScreenState();
}

class _CallHistoryScreenState
    extends State<CallHistoryScreen> {
  final CallHistoryService _historyService =
      CallHistoryService();

  List<CallHistoryModel> callHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCallHistory();
  }

  Future<void> loadCallHistory() async {
    try {
      setState(() {
        isLoading = true;
      });

      final history =
          await _historyService.getCallHistory();

      if (!mounted) return;

      setState(() {
        callHistory = history;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        'Error',
        'Unable to load call history.',
      );

      print('CALL HISTORY ERROR: $e');
    }
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return '${remainingSeconds}s';
    }

    return '${minutes}m ${remainingSeconds}s';
  }

  String formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final minute =
        dateTime.minute.toString().padLeft(2, '0');

    final period =
        dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  IconData getCallIcon(CallHistoryModel call) {
    if (call.callType == 'video') {
      return Icons.videocam;
    }

    return Icons.call;
  }

  Color getStatusColor(CallHistoryModel call) {
    switch (call.status) {
      case 'missed':
        return Colors.red;

      case 'rejected':
        return Colors.orange;

      case 'cancelled':
        return Colors.grey;

      case 'completed':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  String getStatusText(CallHistoryModel call) {
    switch (call.status) {
      case 'missed':
        return 'Missed';

      case 'rejected':
        return 'Rejected';

      case 'cancelled':
        return 'Cancelled';

      case 'completed':
        return 'Completed';

      default:
        return call.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : callHistory.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadCallHistory,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    itemCount: callHistory.length,
                    separatorBuilder: (_, __) =>
                        const Divider(
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      return _buildCallTile(
                        callHistory[index],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No call history',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your calls will appear here',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildCallTile(CallHistoryModel call) {
  final currentUser =
      _historyService.currentUser;

  final isOutgoing =
      call.callerId == currentUser?.uid;

  final otherUserId =
      isOutgoing ? call.receiverId : call.callerId;

  final otherUserName =
      isOutgoing ? call.receiverName : call.callerName;

  final otherUserEmail =
      isOutgoing ? '' : '';

  final statusColor =
      getStatusColor(call);

  return ListTile(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 8,
    ),
    leading: CircleAvatar(
      radius: 25,
      child: Icon(
        getCallIcon(call),
      ),
    ),

    title: Text(
      otherUserName.isNotEmpty
          ? otherUserName
          : 'Unknown User',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),

    subtitle: Row(
      children: [
        Icon(
          isOutgoing
              ? Icons.call_made
              : Icons.call_received,
          size: 15,
          color: statusColor,
        ),
        const SizedBox(width: 5),
        Text(
          getStatusText(call),
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        if (call.status == 'completed')
          Text(
            '• ${formatDuration(call.duration)}',
          ),
      ],
    ),

    trailing: Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        Text(
          formatDateTime(call.timestamp),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 5),
        const Icon(
          Icons.arrow_forward_ios,
          size: 14,
        ),
      ],
    ),

    onTap: () async {
      if (otherUserId.isEmpty) {
        Get.snackbar(
          'Error',
          'User information is unavailable.',
        );
        return;
      }

      try {
        final user =
            await _historyService.getUserById(
          otherUserId,
        );

        if (user == null) {
          Get.snackbar(
            'Error',
            'This user is no longer available.',
          );
          return;
        }

        Get.toNamed(
          '/user-profile',
          arguments: user,
        );
      } catch (e) {
        print(
          'CALL AGAIN ERROR: $e',
        );

        Get.snackbar(
          'Error',
          'Unable to open user profile.',
        );
      }
    },
  );
}}