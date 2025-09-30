package com.example.ohmo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity(){
    private val eventChannel="com.example.ohmo/todo_events"
    private var eventSink:EventChannel.EventSink?=null
    private var broadcastReceiver:BroadcastReceiver?=null

    override fun configureFlutterEngine(flutterEngine:FlutterEngine){
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger,eventChannel).setStreamHandler(
            object :EventChannel.StreamHandler{
                override fun onListen(arguments:Any?,events:EventChannel.EventSink?){
                    eventSink=events
                    registerReceiver()
                }

                override fun onCancel(arguments:Any?){
                    eventSink=null
                    unregisterReceiver()
                }
            }
        )
    }

    private fun registerReceiver(){
        broadcastReceiver=object:BroadcastReceiver(){
            override fun onReceive(context:Context,intent:Intent){
                if(intent.action=="com.example.ohmo.ACTION_UPDATE_TODOS"){
                    val updatedTodosJson=intent.getStringExtra("updated_todos")
                    eventSink?.success(updatedTodosJson)
                }
            }
        }
        registerReceiver(broadcastReceiver,IntentFilter("com.example.ohmo.ACTION_UPDATE_TODOS"))
    }
    private fun unregisterReceiver(){
        if(broadcastReceiver!=null){
            unregisterReceiver(broadcastReceiver)
            broadcastReceiver=null
        }
    }

    override fun onDestroy(){
        unregisterReceiver()
        super.onDestroy()
    }
}
