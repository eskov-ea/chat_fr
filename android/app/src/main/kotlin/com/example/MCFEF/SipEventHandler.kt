package com.example.MCFEF

import android.app.Activity
import io.flutter.plugin.common.EventChannel

class SipEventHandler(private var activity: Activity?) : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }



    override fun onCancel(arguments: Any?) {
        TODO("Not yet implemented")
    }


}