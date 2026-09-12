import 'package:connect_call/core/theme/app_theme.dart';
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour =
        dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute =
        dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    if (date == today) return 'Today, $timeStr';
    if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $timeStr';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}, $timeStr';
  }

  IconData getCallIcon(CallHistoryModel call) {
    if (call.callType == 'video') {
      return Icons.videocam_rounded;
    }
    return Icons.call_rounded;
  }

  Color getStatusColor(CallHistoryModel call) {
    switch (call.status) {
      case 'missed':
        return AppColors.missed;
      case 'rejected':
        return AppColors.rejected;
      case 'cancelled':
        return AppColors.cancelled;
      case 'completed':
        return AppColors.completed;
      default:
        return AppColors.cancelled;
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

  IconData getStatusIcon(CallHistoryModel call, bool isOutgoing) {
    switch (call.status) {
      case 'missed':
        return Icons.call_missed_rounded;
      case 'rejected':
        return Icons.call_end_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'completed':
        return isOutgoing
            ? Icons.call_made_rounded
            : Icons.call_received_rounded;
      default:
        return isOutgoing
            ? Icons.call_made_rounded
            : Icons.call_received_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 2.5,
              ),
            )
          : callHistory.isEmpty
              ? _buildEmptyState(context, colorScheme)
              : RefreshIndicator(
                  color: colorScheme.primary,
                  onRefresh: loadCallHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: callHistory.length,
                    itemBuilder: (context, index) {
                      return _buildCallCard(
                        context,
                        callHistory[index],
                        isDark,
                        colorScheme,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No call history yet',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your calls will appear here',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallCard(
    BuildContext context,
    CallHistoryModel call,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final currentUser = _historyService.currentUser;
    final isOutgoing = call.callerId == currentUser?.uid;
    final otherUserId =
        isOutgoing ? call.receiverId : call.callerId;
    final otherUserName =
        isOutgoing ? call.receiverName : call.callerName;

    final statusColor = getStatusColor(call);
    final callIcon = getCallIcon(call);
    final statusIcon = getStatusIcon(call, isOutgoing);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (otherUserId.isEmpty) {
              Get.snackbar(
                'Error',
                'User information is unavailable.',
              );
              return;
            }

            try {
              final user = await _historyService.getUserById(
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
              print('CALL AGAIN ERROR: $e');
              Get.snackbar(
                'Error',
                'Unable to open user profile.',
              );
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // ── Call type icon bubble ────────────────────────────────
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    callIcon,
                    color: statusColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // ── Name + status ─────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUserName.isNotEmpty
                            ? otherUserName
                            : 'Unknown User',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getStatusText(call),
                            style: textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (call.status == 'completed') ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: colorScheme.onSurfaceVariant,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              formatDuration(call.duration),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (call.callType == 'video') ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'VIDEO',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Timestamp + chevron ───────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatDateTime(call.timestamp),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
