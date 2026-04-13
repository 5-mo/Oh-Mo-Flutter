import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/component/invitation_popup.dart';
import 'package:ohmo/db/drift_database.dart' as db;

enum NotificationType { group, calender, invitation }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final db.LocalDatabase _db = db.LocalDatabaseSingleton.instance;
  late final Stream<List<db.Notification>> _notificationStream;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _markAllAsRead();

    _notificationStream = _db.watchAllNotifications();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _markAllAsRead() {
    unawaited(_db.markAllNotificationsAsRead());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<db.Notification>>(
      stream: _notificationStream,
      builder: (context, snapshot) {
        final allNotifications = snapshot.data ?? [];
        final now = DateTime.now();
        final visibleNotifications =
            allNotifications.where((notification) {
              return notification.timestamp.isBefore(now) ||
                  notification.timestamp.isAtSameMomentAs(now);
            }).toList();

        final bool hasNotifications = visibleNotifications.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            backgroundColor: Colors.white,
            title: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '알림',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontFamily: 'PretendardBold',
                    ),
                  ),
                  if (hasNotifications) ...[
                    const SizedBox(width: 15),
                    const Text(
                      "알림 해제는 휴대폰 설정 앱>알림>'OhMo'에서 설정할 수 있습니다",
                      style: TextStyle(
                        fontFamily: 'PretendardRegular',
                        fontSize: 8.0,
                        color: Color(0xFF565656),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          body: _buildBody(snapshot, visibleNotifications),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<List<db.Notification>> snapshot,
    List<db.Notification> visibleNotifications,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (visibleNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'android/assets/images/notification_off.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 7),
            const Text(
              "최근 알림이 없습니다.",
              style: TextStyle(
                fontFamily: 'PretendardRegular',
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              "알림 해제는 휴대폰 설정 앱>알림>'OhMo'에서\n설정할 수 있습니다",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PretendardRegular',
                fontSize: 12.0,
                height: 1.2,
                color: Color(0xFF565656),
              ),
            ),
            const SizedBox(height: 200),
          ],
        ),
      );
    }

    visibleNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final Map<String, db.Notification> filteredMap = {};

    for (var notification in visibleNotifications) {
      if (notification.content.contains('[Routine]')) {

        final String pureContent = notification.content.trim();


        final String dateGroup = "${notification.timestamp.year}${notification.timestamp.month}${notification.timestamp.day}";

        final String groupKey = "routine_${pureContent}_$dateGroup";

        if (!filteredMap.containsKey(groupKey)) {
          filteredMap[groupKey] = notification;
        }
      } else {
        filteredMap['normal_${notification.id}'] = notification;
      }
    }

    final List<db.Notification> finalNotifications = filteredMap.values.toList();

    finalNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return Column(
      children: [
        const SizedBox(height: 10.0),
        Expanded(child: _buildNotificationList(finalNotifications)),
      ],
    );
  }

  Widget _buildNotificationList(List<db.Notification> notifications) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        bool showHeader = false;

        if (index == 0) {
          showHeader = true;
        } else {
          final prevItem = notifications[index - 1];
          if (!_isSameDay(item.timestamp, prevItem.timestamp)) {
            showHeader = true;
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader) ...[
                if (index != 0) ...[
                  const SizedBox(height: 15),
                  const Divider(
                    color: Color(0xFFE2E2E2),
                    height: 1,
                    thickness: 1,
                  ),
                ],
                _buildDateHeaderWidget(item.timestamp),
              ],
              _buildNotificationItem(item),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(db.Notification item) {
    final type = NotificationType.values.firstWhere(
      (e) => e.name == item.type,
      orElse: () => NotificationType.group,
    );
    String displayContent = item.content;

    Widget contentWidget;
    String? tag;
    int tagIndex = -1;

    if (displayContent.contains('[공지]')) {
      tag = '[공지]';
      tagIndex = displayContent.indexOf(tag);
    } else if (displayContent.contains('[To-do]')) {
      tag = '[To-do]';
      tagIndex = displayContent.indexOf(tag);
    } else if (displayContent.contains('[Routine]')) {
      tag = '[Routine]';
      tagIndex = displayContent.indexOf(tag);
    }

    if ((type == NotificationType.group || type == NotificationType.calender) &&
        tagIndex != -1 &&
        tag != null) {
      final String part1 = displayContent.substring(0, tagIndex);
      final String part2 = tag;
      final String part3 = displayContent.substring(tagIndex + tag.length);
      contentWidget = RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'PretendardRegular',
            fontSize: 12.0,
            color: Colors.black,
            height: 1.3,
          ),
          children: [
            TextSpan(text: part1),
            TextSpan(
              text: part2,
              style: const TextStyle(
                fontFamily: 'PretendardBold',
                fontSize: 12.0,
                color: Color(0xFF808080),
                height: 1.3,
              ),
            ),
            TextSpan(text: part3),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      contentWidget = Text(
        displayContent,
        style: const TextStyle(
          fontFamily: 'PretendardRegular',
          fontSize: 12.0,
          color: Colors.black,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    return ListTile(
      leading: _getIconForType(type),
      title: Transform.translate(
        offset: const Offset(-5, 5),
        child: Text(
          _getTitleForType(type),
          style: const TextStyle(
            fontFamily: 'RubikSprayPaint',
            fontSize: 13.0,
            color: Colors.black,
          ),
        ),
      ),
      subtitle: Transform.translate(
        offset: const Offset(-5, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contentWidget,
            const SizedBox(height: 1.0),
            Text(
              _formatTimestamp(item.timestamp),
              style: const TextStyle(
                fontFamily: 'PretendardRegular',
                fontSize: 10.0,
                color: Color(0xFFB3B3B3),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        if (item.type == 'invitation' && item.relatedId != null) {
          if (item.content.contains('입장했습니다')) {
            return;
          }
          final parts = item.content.split("'");
          String groupName = parts.length > 1 ? parts[1] : '초대된 그룹';

          final bool? result = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (context) => InvitationPopup(
              invitationId: item.relatedId!,
              groupId: item.relatedId!,
              groupName: groupName,
            ),
          );

          if (result == true) {
            await _db.deleteNotificationById(item.id);
          }
        }
      },
    );
  }

  Widget _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.group:
        return Image.asset(
          'android/assets/images/notification_group.png',
          width: 40,
          height: 40,
        );
      case NotificationType.calender:
        return Image.asset(
          'android/assets/images/notification_calender.png',
          width: 40,
          height: 40,
        );
      case NotificationType.invitation:
        return Image.asset(
          'android/assets/images/notification_invitation.png',
          width: 40,
          height: 40,
        );
    }
  }

  String _getTitleForType(NotificationType type) {
    switch (type) {
      case NotificationType.group:
      case NotificationType.invitation:
        return 'Group';
      case NotificationType.calender:
        return 'Calender';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MM/dd HH:mm').format(timestamp);
  }

  Widget _buildDateHeaderWidget(DateTime timestamp) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      width: double.infinity,
      child: Text(
        _formatDateHeaderText(timestamp),
        style: const TextStyle(
          fontFamily: 'PretendardBold',
          fontSize: 14.0,
          color: Colors.black,
        ),
      ),
    );
  }

  String _formatDateHeaderText(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return '  오늘';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(date, yesterday)) return '  어제';
    return DateFormat('  MM월 dd일').format(date);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
