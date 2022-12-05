package com.example.MCFEF.calls_manager

import android.app.Activity
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.os.*
import android.text.TextUtils
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.view.animation.AnimationUtils
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.example.MCFEF.MainActivity
import com.example.MCFEF.R
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.ACTION_CALL_INCOMING
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_INCOMING_DATA
import com.hiennv.flutter_callkit_incoming.Utils
import com.hiennv.flutter_callkit_incoming.widgets.RippleRelativeLayout
import io.flutter.Log
import kotlin.math.abs

class CallsManager : Activity() {

    companion object {

        const val ACTION_ENDED_CALL_INCOMING =
                "com.example.chat_fr.calls_manager.ACTION_ENDED_CALL_INCOMING"
        const val ACTION_CALL_ACCEPTED =
                "com.example.chat_fr.calls_manager.ACTION_CALL_ACCEPTED"

        fun getIntent(data: Bundle) = Intent(ACTION_CALL_INCOMING).apply {
            action = ACTION_CALL_INCOMING
            putExtra(EXTRA_CALLKIT_INCOMING_DATA, data)
            flags =
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }

        fun getIntentEnded() =
                Intent(ACTION_ENDED_CALL_INCOMING)
    }

    inner class EndedCallsManagerBroadcastReceiver : BroadcastReceiver() {
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

    private var endedCallkitIncomingBroadcastReceiver = EndedCallsManagerBroadcastReceiver()


    private lateinit var ivBackground: ImageView
    private lateinit var llBackgroundAnimation: RippleRelativeLayout

    private lateinit var tvNameCaller: TextView
    private lateinit var tvNumber: TextView
    private lateinit var ivLogo: ImageView
//    private lateinit var ivAvatar: MyCircleImageView

    private lateinit var llAction: LinearLayout
    private lateinit var ivAcceptCall: ImageView
    private lateinit var tvAccept: TextView

    private lateinit var ivDeclineCall: ImageView
    private lateinit var tvDecline: TextView

    private val call = MainActivity.Companion.core


    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.w("onCreate", "listen")
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
        setContentView(R.layout.activity_callkit_incoming)
        initView()
        incomingData(intent)
        registerReceiver(
                endedCallkitIncomingBroadcastReceiver,
                IntentFilter(ACTION_ENDED_CALL_INCOMING)
        )
    }

    private fun initView() {
        ivBackground = findViewById(R.id.ivBackground)
        llBackgroundAnimation = findViewById(R.id.llBackgroundAnimation)
        llBackgroundAnimation.layoutParams.height =
                Utils.getScreenWidth() + Utils.getStatusBarHeight(this)
        llBackgroundAnimation.startRippleAnimation()

        tvNameCaller = findViewById(R.id.tvNameCaller)
        tvNumber = findViewById(R.id.tvNumber)
        ivLogo = findViewById(R.id.ivLogo)
//        ivAvatar = findViewById(R.id.ivAvatar)

        llAction = findViewById(R.id.llAction)

        val params = llAction.layoutParams as ViewGroup.MarginLayoutParams
        params.setMargins(0,0,0, Utils.getNavigationBarHeight(this))
        llAction.layoutParams = params

        ivAcceptCall = findViewById(R.id.ivAcceptCall)
        tvAccept = findViewById(R.id.tvAccept)
        ivDeclineCall = findViewById(R.id.ivDeclineCall)
        tvDecline = findViewById(R.id.tvDecline)
        animateAcceptCall()

        ivAcceptCall.setOnClickListener {
            onAcceptClick()
        }
        ivDeclineCall.setOnClickListener {
            onDeclineClick()
        }
    }

    private fun incomingData(intent: Intent) {
        val data = intent.extras?.getBundle(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_INCOMING_DATA)
        val caller = intent.getStringExtra("CALLS_MANAGER_EXTRAS_CALLERNAME")
//        if (data == null) finish()
        tvNameCaller.text = caller
        tvNumber.text = data?.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HANDLE, "")

        val isShowLogo = data?.getBoolean(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_LOGO, false)
        ivLogo.visibility = if (isShowLogo == true) View.VISIBLE else View.INVISIBLE

        val avatarUrl = data?.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_AVATAR, "")
//        if (avatarUrl != null && avatarUrl.isNotEmpty()) {
//            ivAvatar.visibility = View.VISIBLE
//            val headers = data.getSerializable(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HEADERS) as HashMap<String, Any?>
//            getPicassoInstance(this, headers)
//                    .load(avatarUrl)
//                    .placeholder(R.drawable.ic_default_avatar)
//                    .error(R.drawable.ic_default_avatar)
//                    .into(ivAvatar)
//        }

        val callType = data?.getInt(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TYPE, 0) ?: 0
        if (callType > 0) {
            ivAcceptCall.setImageResource(R.drawable.ic_video)
        }
        val duration = data?.getLong(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_DURATION, 0L) ?: 0L
        wakeLockRequest(duration)
//
        finishTimeout(data, duration)

        val textAccept = data?.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_ACCEPT, "")
        tvAccept.text = if(TextUtils.isEmpty(textAccept)) getString(R.string.text_accept) else textAccept
        val textDecline = data?.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_DECLINE, "")
        tvDecline.text = if(TextUtils.isEmpty(textDecline)) getString(R.string.text_decline) else textDecline

        val backgroundColor = data?.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_BACKGROUND_COLOR, "#0955fa")
        try {
            ivBackground.setBackgroundColor(Color.parseColor(backgroundColor))
        } catch (error: Exception) {
        }
        val backgroundUrl = data?.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_BACKGROUND_URL, "")
//        if (backgroundUrl != null && backgroundUrl.isNotEmpty()) {
//            val headers = data.getSerializable(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HEADERS) as HashMap<String, Any?>
//            getPicassoInstance(this@CallkitIncomingActivity, headers)
//                    .load(backgroundUrl)
//                    .placeholder(R.drawable.transparent)
//                    .error(R.drawable.transparent)
//                    .into(ivBackground)
//        }
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

    private fun onAcceptClick(){
//        getIntentAccepted()
        val data = intent.extras?.getBundle(EXTRA_CALLKIT_INCOMING_DATA)
        val intent = packageManager.getLaunchIntentForPackage(packageName)?.cloneFilter()
        if (isTaskRoot) {
            intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        } else {
            intent?.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        if (intent != null) {
            val intentTransparent = TransparentActivity.getIntentAccept(this, data)
            startActivities(arrayOf(intent, intentTransparent))
        } else {
            val acceptIntent = CallsManagerBroadcastReceiver.getIntentAccept(this, data)
            sendBroadcast(acceptIntent)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            finishAndRemoveTask()
        } else {
            finish()
        }
    }
//    private  fun onDeclineClick(){
//        this.stopService(Intent(this, CallkitSoundPlayerService::class.java))
//        call.currentCall?.decline(Reason.Declined)
//        finish()
//    }
    private fun onDeclineClick() {
        val data = intent.extras?.getBundle(EXTRA_CALLKIT_INCOMING_DATA)
        Log.w("ACTION_CALL_DECLINE", "$data")
        val intent =
                CallsManagerBroadcastReceiver.getIntentDecline(this, data)
        sendBroadcast(intent)
    }

    private fun animateAcceptCall() {
        val shakeAnimation =
                AnimationUtils.loadAnimation(this, R.anim.shake_anim)
        ivAcceptCall.animation = shakeAnimation
    }

    override fun onDestroy() {
        unregisterReceiver(endedCallkitIncomingBroadcastReceiver)
        super.onDestroy()
    }

    override fun onBackPressed() {}
}