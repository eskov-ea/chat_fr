//package com.example.MCFEF.calls_manager
//
//import android.os.Handler
//import android.os.Looper
//import android.widget.TextView
//
//class CallsTimer( textField: TextView?) {
//
//    private var running = false
//    private var seconds = 0
//    val handler = Handler(Looper.getMainLooper())
//    private var runnable: Runnable = object : Runnable {
//        override fun run() {
//            textField?.text = makeTime()
//            if (running == true) {
//                seconds++
//            }
//            handler.postDelayed(this, 1000)
//        }
//    }
//
//    fun onStart() {
//        running = true
//        runnable.run()
//    }
//
//    fun getTime(): Int {
//        running = false
//        return seconds
//    }
//
//    fun makeTime(): String {
//        var minutes: String = ""
//        var secs: String = ""
//        val hours = seconds / 3600
//        if (seconds % 60< 10) {
//            secs = "0${(seconds % 60)}"
//        } else {
//            secs = "${(seconds % 60)}"
//        }
//        if (seconds % 3600 / 60 < 10) {
//            minutes = "0${(seconds % 3600 / 60)}"
//        } else {
//            minutes = "${(seconds % 3600 / 60)}"
//        }
//        return "$hours:$minutes:$secs"
//    }
//
//
//
//
//}