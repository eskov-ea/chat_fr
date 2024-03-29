package com.example.MCFEF.calls_manager

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log

class TransparentActivity : Activity() {

    companion object {

        fun getIntentAccept(context: Context, data: Bundle?): Intent {
            val intent = Intent(context, TransparentActivity::class.java)
            intent.putExtra("data", data)
            intent.putExtra("type", "ACCEPT")
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
            return intent
        }

        fun getIntentCallback(context: Context, data: Bundle?): Intent {
            val intent = Intent(context, TransparentActivity::class.java)
            intent.putExtra("data", data)
            intent.putExtra("type", "CALLBACK")
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
            return intent
        }

    }


    override fun onStart() {
        super.onStart()
        setVisible(true)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.w("TransparentActivity", "TransparentActivity")
        when (intent.getStringExtra("type")) {
            "ACCEPT" -> {
                val data = intent.getBundleExtra("data")
                val acceptIntent = CallsManagerBroadcastReceiver.getIntentAccept(this, data)
                sendBroadcast(acceptIntent)
            }
            "CALLBACK" -> {
                val data = intent.getBundleExtra("data")
                val acceptIntent = CallsManagerBroadcastReceiver.getIntentCallback(this, data)
                sendBroadcast(acceptIntent)
            }
            else -> { // Note the block
                val data = intent.getBundleExtra("data")
                val acceptIntent = CallsManagerBroadcastReceiver.getIntentAccept(this, data)
                sendBroadcast(acceptIntent)
            }
        }
        finish()
        overridePendingTransition(0, 0)
    }
}