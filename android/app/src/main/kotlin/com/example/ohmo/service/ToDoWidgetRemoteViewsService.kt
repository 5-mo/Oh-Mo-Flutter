package com.example.ohmo.service

import android.content.Intent
import android.widget.RemoteViewsService
import com.example.ohmo.factory.ToDoWidgetRemoteViewsFactory

class ToDoWidgetRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return ToDoWidgetRemoteViewsFactory(this.applicationContext, intent)
    }
}