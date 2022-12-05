package com.example.MCFEF.calls_manager

import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.AudioManager.STREAM_RING
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.view.animation.LinearInterpolator
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.StringRes
import com.example.MCFEF.MainActivity
import com.example.MCFEF.R
import io.flutter.Log
import java.io.IOException

class RingingCall: Activity() {

    companion object {
        const val ACTION_ENDED_CALL_INCOMING =
                "com.example.chat_fr.calls_manager.ACTION_ENDED_CALL_INCOMING"

        fun getIntentEnded() =
                Intent(CallsManager.ACTION_ENDED_CALL_INCOMING)
    }

    inner class EndedCallsManagerBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            stopMediaPlayer()
        }
    }

    private var endedCallkitIncomingBroadcastReceiver = EndedCallsManagerBroadcastReceiver()

    val name = MainActivity.core.currentCall?.toAddress?.username
    lateinit var tvCalling: TextView
    val mediaPlayer = MediaPlayer()

    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.outgoing_call)
        tvCalling = findViewById<TextView>(R.id.tvNameCaller)
        tvCalling.text = name
        findViewById<ImageView>(R.id.ivDeclineCallButton).setOnClickListener{
            onDeclineClick()
        }
        registerReceiver(
                endedCallkitIncomingBroadcastReceiver,
                IntentFilter(CurrentCall.ACTION_ENDED_CALL_INCOMING)
        )
        dotsAnimator?.start()
        useRingbackSound(this)
    }

    private fun getDotAnimator(
            textView: TextView,
            dotCount: Int,
            list: List<CharSequence>
    ): ValueAnimator {
        val valueTo = dotCount + 1

        return ValueAnimator.ofInt(0, valueTo).apply {
            this.interpolator = LinearInterpolator()
            this.duration = textView.context.resources.getInteger(R.integer.dots_anim_time).toLong()
            this.repeatCount = ObjectAnimator.INFINITE
            this.repeatMode = ObjectAnimator.RESTART

            addUpdateListener {
                val value = it.animatedValue as? Int


                /**
                 * Sometimes [ValueAnimator] give a corner value.
                 */
                if (value == null || value == valueTo) return@addUpdateListener

                textView.text = list.getOrNull(value)
            }
        }
    }

    fun getDotsSpanAnimator(textView: TextView?, @StringRes stringId: Int): ValueAnimator? {
        val context = textView?.context ?: return null

        val simpleText = context.getString(stringId)
        val dotText = context.getString(R.string.dot)
        val dotCount = 3

        val resultText = StringBuilder(simpleText).apply {
            repeat(dotCount) { append(dotText) }
        }.toString()

        val textList = mutableListOf<SpannableString>()
        for (i in 0 until dotCount + 1) {
            val spannable = SpannableString(resultText)

            val start = resultText.length - (dotCount - i)
            val end = resultText.length
            val flag = Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            spannable.setSpan(ForegroundColorSpan(Color.TRANSPARENT), start, end, flag)

            textList.add(spannable)
        }

        return getDotAnimator(textView, dotCount, textList)
    }

    private val dotsAnimator by lazy {
        getDotsSpanAnimator(tvCalling, R.string.dialog_text_loading)
    }

    private fun onDeclineClick() {
        MainActivity.core.currentCall?.terminate()
        stopMediaPlayer()
    }

    fun stopMediaPlayer() {
        mediaPlayer.stop()
        if (!isFinishing) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                finishAndRemoveTask()
            } else {
                finish()
            }
        }
    }

    private fun useRingbackSound(context: Context){
//        try {
//            mediaPlayer.setDataSource(context, RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE))
//            mediaPlayer.setAudioAttributes(
//                    AudioAttributes
//                            .Builder()
//                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
//                            .build());
//            mediaPlayer.prepare()
//            mediaPlayer.start()
//        } catch (e1: IllegalArgumentException) {
//            e1.printStackTrace()
//        } catch (e1: SecurityException) {
//            e1.printStackTrace()
//        } catch (e1: IllegalStateException) {
//            e1.printStackTrace()
//        } catch (e1: IOException) {
//            e1.printStackTrace()
//        }
    }

    override fun onDestroy() {
        Log.w("onDestroy", "onDestroy CURRENT_CALL")
        stopMediaPlayer()
        unregisterReceiver(endedCallkitIncomingBroadcastReceiver)
        super.onDestroy()
    }


}