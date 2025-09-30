package com.example.ohmo.factory

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.example.ohmo.R
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale


class CalendarWidgetRemoteViewsFactory(
    private val context: Context,
    private val intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private val eventItems = mutableListOf<String>()

    override fun onDataSetChanged() {
        eventItems.clear()

        val dateIndex = intent.getIntExtra("date_index", 0)

        val calendar = Calendar.getInstance().apply {
            firstDayOfWeek = Calendar.SUNDAY
            set(Calendar.DAY_OF_WEEK, firstDayOfWeek)
            add(Calendar.DAY_OF_YEAR, dateIndex)
        }
        val targetDate = calendar.time

        val dateKeyFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val dateKey = dateKeyFormat.format(targetDate)

        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val calendarJsonString = prefs.getString("calendar_todos", null)

        if (dateIndex==0){

        }


        calendarJsonString?.let {
            try {
                val jsonObject = JSONObject(it)
                val jsonArray = jsonObject.optJSONArray(dateKey)

                jsonArray?.let { array ->
                    for (i in 0 until array.length()) {
                        val eventObject = array.getJSONObject(i)
                        eventItems.add(eventObject.getString("content"))
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun getCount(): Int = eventItems.size

    override fun getViewAt(position: Int): RemoteViews {
        val rv = RemoteViews(context.packageName, R.layout.widget_schedule_item)
        rv.setTextViewText(R.id.schedule_item_text, eventItems[position])
        return rv
    }

    override fun onCreate() {
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true

    override fun onDestroy() {
    }
}