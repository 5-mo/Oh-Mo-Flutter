import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();

    _markAllAsRead();

    _notificationStream = _db.watchAllNotifications();
  }

  void _markAllAsRead() {
    unawaited(_db.markAllNotificationsAsRead());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontFamily: 'PretendardBold',
          ),
        ),
        centerTitle: false,
        titleSpacing: 3.0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildNotificationHeader(),
          SizedBox(height: 10.0),
          Expanded(
            child: StreamBuilder<List<db.Notification>>(
              stream: _notificationStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(height: 200),
                      SvgPicture.asset('android/assets/images/notification_off.svg',width: 24,height: 24,),
                      SizedBox(height: 7),
                      Text(
                        "최근 알림이 없습니다.",
                        style: TextStyle(
                          fontFamily: 'PretendardRegular',
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        textAlign: TextAlign.right,
                        "알림 해제는 휴대폰 설정 앱>알림>'OhMo'에서 설정할 수 있습니다",
                        style: TextStyle(
                          fontFamily: 'PretendardRegular',
                          fontSize: 8.0,
                          color: Color(0xFF565656),
                        ),
                      ),
                    ],
                  );
                }

                final notifications = snapshot.data!;
                return _buildNotificationList(notifications);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          padding: EdgeInsets.symmetric(horizontal: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textAlign: TextAlign.right,
                "알림 해제는 휴대폰 설정 앱>알림>'OhMo'에서 설정할 수 있습니다",
                style: TextStyle(
                  fontFamily: 'PretendardRegular',
                  fontSize: 8.0,
                  color: Color(0xFF565656),
                ),
              ),
              if (showHeader) ...[
                if (index != 0) ...[
                  SizedBox(height: 15),
                  Divider(color: Color(0xFFE2E2E2), height: 1, thickness: 1),
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
    if (type == NotificationType.calender) {
      final timeString = DateFormat('HH:mm').format(item.timestamp);
      displayContent = '$timeString ${item.content}';
    }
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

    if (type == NotificationType.group && tagIndex != -1 && tag != null) {
      final String part1 = displayContent.substring(0, tagIndex);
      final String part2 = tag;
      final String part3 = displayContent.substring(tagIndex + tag.length);
      contentWidget = RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'PretendardRegular',
            fontSize: 12.0,
            color: Colors.black,
            height: 1.3,
          ),
          children: [
            TextSpan(text: part1),
            TextSpan(
              text: part2,
              style: TextStyle(
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
        style: TextStyle(
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
        offset: Offset(-5, 5),
        child: Text(
          _getTitleForType(type),
          style: TextStyle(
            fontFamily: 'RubikSprayPaint',
            fontSize: 13.0,
            color: Colors.black,
          ),
        ),
      ),
      subtitle: Transform.translate(
        offset: Offset(-5, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contentWidget,
            SizedBox(height: 1.0),
            Text(
              _formatTimestamp(item.timestamp),
              style: TextStyle(
                fontFamily: 'PretendardRegular',
                fontSize: 10.0,
                color: Color(0xFFB3B3B3),
              ),
            ),
          ],
        ),
      ),
      trailing: null,
      onTap: () {},
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
        return 'Group';
      case NotificationType.calender:
        return 'Calender';
      case NotificationType.invitation:
        return 'Group';
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
        style: TextStyle(
          fontFamily: 'PretendardBold',
          fontSize: 14.0,
          color: Colors.black,
        ),
      ),
    );
  }

  String _formatDateHeaderText(DateTime date) {
    final now = DateTime.now();

    if (_isSameDay(date, now)) {
      return '  오늘';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(date, yesterday)) {
      return '  어제';
    }
    return DateFormat('  MM월 dd일').format(date);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
