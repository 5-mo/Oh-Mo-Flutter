package com.example.ohmo.factory

import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.example.ohmo.R

class CalenderWidgetRemoteViewsFactory (
    private val context: android.content.Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private val scheduleItems = mutableListOf<String>() // 예시: 일정 텍스트 리스트
    private val dateIndex: Int = intent.getIntExtra("date_index", 0) // 날짜 인덱스 (0~6)

    override fun onCreate() {
        // 초기 데이터 로드 (예: 날짜별 일정)
        loadScheduleForDate(dateIndex)
    }

    override fun onDataSetChanged() {
        // 데이터 변경 시 호출
        loadScheduleForDate(dateIndex)
    }

    private fun loadScheduleForDate(index: Int) {
        scheduleItems.clear()
        when (index) {
            0 -> scheduleItems.addAll(listOf("C", "스터디 모임"))
            1 -> scheduleItems.addAll(listOf("회의", "약속"))
            else -> scheduleItems.add("일정 없음ㅡㅡㅡㅡㅡㅡ")
        }
    }

    override fun getCount(): Int = scheduleItems.size

    override fun getViewAt(position: Int): RemoteViews {
        val rv = RemoteViews(context.packageName, R.layout.widget_schedule_item)
        rv.setTextViewText(R.id.schedule_item_text, scheduleItems[position])
        return rv
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true

    override fun onDestroy() {
        scheduleItems.clear()
    }
}