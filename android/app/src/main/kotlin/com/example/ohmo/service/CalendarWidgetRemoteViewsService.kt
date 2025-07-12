package com.example.ohmo.service

import android.content.Intent
import android.widget.RemoteViewsService
import com.example.ohmo.factory.CalenderWidgetRemoteViewsFactory

class CalendarWidgetRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return CalenderWidgetRemoteViewsFactory(this.applicationContext, intent)
    }
}