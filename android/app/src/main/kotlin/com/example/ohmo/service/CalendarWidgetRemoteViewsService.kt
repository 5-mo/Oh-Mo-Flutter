package com.example.ohmo.service

import android.content.Intent
import android.widget.RemoteViewsService
import com.example.ohmo.factory.CalendarWidgetRemoteViewsFactory

class CalendarWidgetRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return CalendarWidgetRemoteViewsFactory(this.applicationContext, intent)
    }
}