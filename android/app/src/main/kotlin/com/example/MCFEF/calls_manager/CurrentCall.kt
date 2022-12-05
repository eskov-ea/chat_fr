package com.example.MCFEF.calls_manager

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.widget.ImageView
import android.widget.TextView
import com.example.MCFEF.MainActivity
import com.example.MCFEF.R
import io.flutter.Log
import org.linphone.core.AudioDevice

class CurrentCall : Activity() {

    companion object {
        const val ACTION_ENDED_CALL_INCOMING =
                "com.example.chat_fr.calls_manager.ACTION_ENDED_CALL_INCOMING"

        fun getIntentEnded() =
                Intent(CallsManager.ACTION_ENDED_CALL_INCOMING)
    }
    lateinit var timerTextView: TextView
    lateinit var speakerBtn : ImageView
    lateinit var muteBtn : ImageView
    var isSpeaker: Boolean = false

    inner class EndedCallsManagerBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            Log.w("CURRENT_CALL", "CURRENT_CALL")
            if (!isFinishing) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    finishAndRemoveTask()
                } else {
                    finish()
                }
            }
        }
    }

    private var endedCallkitIncomingBroadcastReceiver = EndedCallsManagerBroadcastReceiver()


    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.ongoing_call_layout)
        timerTextView= findViewById<TextView>(R.id.tvTimer)
        initView()
        registerReceiver(
                endedCallkitIncomingBroadcastReceiver,
                IntentFilter(ACTION_ENDED_CALL_INCOMING)
        )
        CallsTimer(timerTextView).onStart()
    }

    private fun initView() {
        findViewById<TextView>(R.id.tvNameCaller).text = MainActivity.core.currentCall?.toAddress?.username
        muteBtn = findViewById<ImageView>(R.id.ivMuteCallButton)
        muteBtn.setOnClickListener{
            if (MainActivity.core.micEnabled()) {
                muteBtn.setBackgroundResource(R.drawable.bg_button_active)
            } else {
                muteBtn.setBackgroundResource(R.drawable.bg_button)
            }
            MainActivity.core.enableMic(!MainActivity.core.micEnabled())
        }

        speakerBtn = findViewById<ImageView>(R.id.ivSpeakerCallButton)
        speakerBtn.setOnClickListener {
            toggleSpeaker()
        }
        findViewById<ImageView>(R.id.ivDeclineCallButton).setOnClickListener{
            onDeclineClick()
        }
    }

    private fun onDeclineClick() {
        MainActivity.core.currentCall?.terminate()
        val callTime = CallsTimer(timerTextView).getTime()
        MainActivity.eventSink?.success(callTime)
        if (!isFinishing) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                finishAndRemoveTask()
            } else {
                finish()
            }
        }
    }

    override fun onDestroy() {
        unregisterReceiver(endedCallkitIncomingBroadcastReceiver)
        super.onDestroy()
    }

    private fun toggleSpeaker() {
        // Get the currently used audio device
        val currentAudioDevice = MainActivity.core.currentCall?.outputAudioDevice
        val speakerEnabled = currentAudioDevice?.type == AudioDevice.Type.Speaker

        Log.w("toggleSpeaker", speakerEnabled.toString())

        // We can get a list of all available audio devices using
        // Note that on tablets for example, there may be no Earpiece device
        for (audioDevice in MainActivity.core.audioDevices) {
//            Log.w("toggleSpeaker", audioDevice.type.toString())

            if (speakerEnabled && audioDevice.type == AudioDevice.Type.Earpiece) {
                Log.w("toggleSpeaker", "AudioDevice.Type.Microphone")

                MainActivity.core.currentCall?.outputAudioDevice = audioDevice
                isSpeaker = false
                Log.w("toggleSpeaker", (MainActivity.core.currentCall?.outputAudioDevice?.type == AudioDevice.Type.Speaker).toString())
            } else if (!speakerEnabled && audioDevice.type == AudioDevice.Type.Speaker) {
                Log.w("toggleSpeaker", "AudioDevice.Type.Speaker")

                MainActivity.core.currentCall?.outputAudioDevice = audioDevice
                isSpeaker = true
            } else if (audioDevice.type == AudioDevice.Type.Bluetooth) {
                MainActivity.core.currentCall?.outputAudioDevice = audioDevice
                isSpeaker = true
            }
            if (isSpeaker) {
                speakerBtn.setBackgroundResource(R.drawable.bg_button_active)
            } else {
                speakerBtn.setBackgroundResource(R.drawable.bg_button)
            }
        /* If we wanted to route the audio to a bluetooth headset

            */
        }
    }



}