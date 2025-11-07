import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum NotificationType { group, calender, invitation }

class NotificationItem {
  final NotificationType type;
  final String content;
  final DateTime timestamp;

  NotificationItem({
    required this.type,
    required this.content,
    required this.timestamp,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      type: NotificationType.calender,
      content: "‘사이드 프로젝트’ 그룹에 새로운 할 일이 등록되었습니다.",
      timestamp: DateTime.now(),
    ),
    NotificationItem(
      type: NotificationType.calender,
      content: "‘사이드 프로젝트’ 그룹에 새로운 공지가 등록되었습니다.",
      timestamp: DateTime.now(),
    ),
    NotificationItem(
      type: NotificationType.calender,
      content: "10:00 식물 물주기",
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationItem(
      type: NotificationType.invitation,
      content: "‘사이드 프로젝트’ 그룹에 입장했습니다.",
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
          Expanded(child: _buildNotificationList()),
        ],
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        textAlign: TextAlign.right,
        "알림 해제는 휴대폰 설정 앱>알림>'OhMo'에서 설정할 수 있습니다",
        style: TextStyle(
          fontFamily: 'PretendardRegular',
          fontSize: 8.0,
          color: Color(0xFF565656),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Text(
          "새로운 알림이 없습니다.",
          style: TextStyle(
            fontFamily: 'PretendardRegular',
            fontSize: 16.0,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final item = _notifications[index];
        bool showHeader = false;

        if (index == 0) {
          showHeader = true;
        } else {
          final prevItem = _notifications[index - 1];
          if (!_isSameDay(item.timestamp, prevItem.timestamp)) {
            showHeader = true;
          }
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  Widget _buildNotificationItem(NotificationItem item) {
    return ListTile(
      leading: _getIconForType(item.type),
      title: Transform.translate(
        offset: Offset(-5, 5),
        child: Text(
          _getTitleForType(item.type),
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
            Text(
              item.content,
              style: TextStyle(
                fontFamily: 'PretendardRegular',
                fontSize: 12.0,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
          width: 80,
          height: 80,
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
