package com.example.ohmo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation


class TodoUpdateReceiver : BroadcastReceiver(){

    override fun onReceive(context:Context,intent:Intent){
        if(intent.action=="com.example.ohmo.ACTION_UPDATE_TODOS"){
            val updatedTodosJson=intent.getStringExtra("updated_todos")

            val loader=FlutterLoader()
            loader.startInitialization(context)
            loader.ensureInitializationComplete(context,null)

            val prefs=context.getSharedPreferences("FlutterSharedPreferences",Context.MODE_PRIVATE)
            val callbackHandle=prefs.getLong("flutter.background_callback_handle",0L)
            if(callbackHandle==0L){
                return
            }

            val callbackInfo=FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
            val dartCallback=DartExecutor.DartCallback(context.assets,loader.findAppBundlePath(),callbackInfo)

            val backgroundEngine=FlutterEngine(context)
            backgroundEngine.dartExecutor.executeDartCallback(dartCallback)
            MethodChannel(backgroundEngine.dartExecutor.binaryMessenger,"com.example.ohmo/todo_events")
                .invokeMethod("updateTodosFromWidget",updatedTodosJson)
        }
    }
}
