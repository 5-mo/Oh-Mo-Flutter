package com.example.ohmo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri // Uri 임포트 추가
import android.widget.RemoteViews

class MyAppWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // 앱 위젯 클릭 시 앱 실행 Intent 설정 (플러터 앱 메인 액티비티)
            val appIntent = Intent(context, MainActivity::class.java)
            val appPendingIntent = PendingIntent.getActivity(context, 0, appIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            views.setOnClickPendingIntent(R.id.widget_layout, appPendingIntent)

            // ListView에 RemoteViewsService 연결
            val serviceIntent = Intent(context, WidgetRemoteViewsService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                // 데이터 URI를 설정하여 PendingIntent가 고유하도록 만듭니다.
                // 이는 ListView에서 여러 위젯 인스턴스를 처리할 때 중요합니다.
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(android.R.id.list, serviceIntent) // @android:id/list 대신 R.id.list 사용

            // 'check' 버튼 (button_left_icon) 클릭 시 모달 화면 띄우기
            val modalIntent = Intent(context, ModalActivity::class.java)
            val modalPendingIntent = PendingIntent.getActivity(context, 0, modalIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            views.setOnClickPendingIntent(R.id.button_left_icon, modalPendingIntent) // '+' 버튼 ID

            // (선택 사항) 리스트가 비어있을 때 표시할 뷰 설정
            // views.setEmptyView(android.R.id.list, R.id.empty_list_view_id)
            // empty_list_view_id는 widget_layout.xml에 추가해야 합니다.

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}