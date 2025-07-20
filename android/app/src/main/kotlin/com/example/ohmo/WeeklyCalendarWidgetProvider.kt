package com.example.ohmo

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.example.ohmo.service.CalendarWidgetRemoteViewsService
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

class WeeklyCalendarWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {

            updateAppWidget(context, appWidgetManager, appWidgetId)

            val views = RemoteViews(context.packageName, R.layout.widget_weekly_calendar)

            for (i in 0..6) {
                val serviceIntent = Intent(context, CalendarWidgetRemoteViewsService::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                    putExtra("date_index", i) // 날짜 인덱스 전달
                    data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
                }
                val listViewId = context.resources.getIdentifier("date_${i}_event_list", "id", context.packageName)
                if (listViewId != 0) {
                    views.setRemoteAdapter(listViewId, serviceIntent)
                    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, listViewId)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.widget_weekly_calendar)

        val calendar = Calendar.getInstance()
        // 주의: Calendar.DAY_OF_WEEK는 일요일이 1, 토요일이 7입니다.
        // 월요일부터 시작하는 주간 달력을 원한다면 로직을 조정해야 합니다.
        // 여기서는 일요일부터 시작하는 주로 가정합니다. (일,월,화,수,목,금,토)

        // 현재 주의 첫째 날 (일요일)로 이동
        calendar.firstDayOfWeek = Calendar.SUNDAY // 주의 시작을 일요일로 설정
        calendar.set(Calendar.DAY_OF_WEEK, calendar.firstDayOfWeek)

        val dateFormat = SimpleDateFormat("dd", Locale.getDefault()) // 날짜만 표시 (예: 01, 15)

        // 각 요일의 날짜를 TextView에 설정
        for (i in 0..6) {
            val dateText = dateFormat.format(calendar.time)
            val resId = context.resources.getIdentifier("date_$i", "id", context.packageName)
            if (resId != 0) {
                views.setTextViewText(resId, dateText)
            }
            calendar.add(Calendar.DAY_OF_YEAR, 1) // 다음 날짜로 이동
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}