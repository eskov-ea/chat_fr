package com.cashalot.MCFEF.calls_manager

import android.app.Activity
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.os.*
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import com.cashalot.MCFEF.R
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.ACTION_CALL_INCOMING
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_DURATION
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_INCOMING_DATA
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_NAME_CALLER
import kotlin.math.abs

class IncomingCallActivity : Activity() {

    companion object {

        const val ACTION_ENDED_CALL_INCOMING =
                "com.cashalot.MCFEF.calls_manager.ACTION_ENDED_CALL_INCOMING"

        fun getIntent(data: Bundle) = Intent(ACTION_CALL_INCOMING).apply {
            action = ACTION_CALL_INCOMING
            putExtra(EXTRA_CALLKIT_INCOMING_DATA, data)
            flags =
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }

        fun getIntentEnded() =
                Intent(ACTION_ENDED_CALL_INCOMING)
    }

    inner class EndedIncomingCallActivityBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (!isFinishing) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    finishAndRemoveTask()
                } else {
                    finish()
                }
            }
        }
    }

    private var endedIncomingCallActivityBroadcastReceiver = EndedIncomingCallActivityBroadcastReceiver()

    private lateinit var tvNameCaller: TextView
    private lateinit var ivAcceptCallButton: ImageView
    private lateinit var tvAccept: TextView
    private lateinit var ivDeclineCallButton: ImageView
    private lateinit var tvDecline: TextView


    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            setTurnScreenOn(true)
            setShowWhenLocked(true)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
            window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        }

        setContentView(R.layout.incoming_call)
        initView()
        incomingData(intent)
        registerReceiver(
            endedIncomingCallActivityBroadcastReceiver,
            IntentFilter(ACTION_ENDED_CALL_INCOMING)
        )
    }

    private fun initView() {
        tvNameCaller = findViewById(R.id.tvNameCaller)
        ivAcceptCallButton = findViewById(R.id.ivAcceptCallButton)
        tvAccept = findViewById(R.id.tvAccept)
        ivDeclineCallButton = findViewById(R.id.ivDeclineCallButton)
        tvDecline = findViewById(R.id.tvDecline)

        ivAcceptCallButton.setOnClickListener {
            onAcceptClick()
        }
        ivDeclineCallButton.setOnClickListener {
            onDeclineClick()
        }
    }

    private fun incomingData(intent: Intent) {
        val data = intent.extras?.getBundle(EXTRA_CALLKIT_INCOMING_DATA)
        if (data == null) finish()
        val caller = intent.extras?.getBundle(EXTRA_CALLKIT_NAME_CALLER)

        tvNameCaller.text = data?.getString(EXTRA_CALLKIT_NAME_CALLER)

        val duration = data?.getLong(EXTRA_CALLKIT_DURATION, 0L) ?: 0L
        wakeLockRequest(duration)

        finishTimeout(data, duration)

    }
    private fun wakeLockRequest(duration: Long) {

        val pm = applicationContext.getSystemService(POWER_SERVICE) as PowerManager
        val wakeLock = pm.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "Callkit:PowerManager"
        )
        wakeLock.acquire(duration)
    }

    private fun finishTimeout(data: Bundle?, duration: Long) {
        val currentSystemTime = System.currentTimeMillis()
        val timeStartCall =
                data?.getLong(CallsNotificationManager.EXTRA_TIME_START_CALL, currentSystemTime)
                        ?: currentSystemTime

        val timeOut = duration - abs(currentSystemTime - timeStartCall)
        Handler(Looper.getMainLooper()).postDelayed({
            if (!isFinishing) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    finishAndRemoveTask()
                } else {
                    finish()
                }
            }
        }, timeOut)
    }

    private fun transparentStatusAndNavigation() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            setWindowFlag(
                    WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                            or WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION, true
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            setWindowFlag(
                    (WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                            or WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION), false
            )
            window.statusBarColor = Color.TRANSPARENT
            window.navigationBarColor = Color.TRANSPARENT
        }
    }

    private fun setWindowFlag(bits: Int, on: Boolean) {
        val win: Window = window
        val winParams: WindowManager.LayoutParams = win.attributes
        if (on) {
            winParams.flags = winParams.flags or bits
        } else {
            winParams.flags = winParams.flags and bits.inv()
        }
        win.attributes = winParams
    }

    private fun onAcceptClick(){
        val data = intent.extras?.getBundle(EXTRA_CALLKIT_INCOMING_DATA)
        val acceptIntent = TransparentActivity.getIntent(this, CallsManagerBroadcastReceiver.ACTION_CALL_ACCEPT, data)
        startActivity(acceptIntent)

        dismissKeyguard()
        finish()
    }
    private fun dismissKeyguard() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        }
    }
    private fun onDeclineClick() {
        val data = intent.extras?.getBundle(EXTRA_CALLKIT_INCOMING_DATA)
        val intent =
                CallsManagerBroadcastReceiver.getIntentDecline(this, data)
        sendBroadcast(intent)
    }

    override fun onDestroy() {
        unregisterReceiver(endedIncomingCallActivityBroadcastReceiver)
        super.onDestroy()
    }

    override fun onBackPressed() {}
}