package com.example.MCFEF

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.ViewGroup
import android.view.WindowManager
import android.view.animation.AnimationUtils
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver
import com.example.MCFEF.calls_manager.TransparentActivity
import com.hiennv.flutter_callkit_incoming.Utils
import com.hiennv.flutter_callkit_incoming.widgets.RippleRelativeLayout
import io.flutter.Log


class IncomingCallActivity() : AppCompatActivity() {

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

    override fun onCreate(savedInstanceState: Bundle?) {
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
        setContentView(R.layout.activity_callkit_incoming)
        initView()
//        incomingData(intent)
//        registerReceiver(
//                endedCallkitIncomingBroadcastReceiver,
//                IntentFilter(CallsManager.ACTION_ENDED_CALL_INCOMING)
//        )
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

    private fun animateAcceptCall() {
        val shakeAnimation =
                AnimationUtils.loadAnimation(this, R.anim.shake_anim)
        ivAcceptCall.animation = shakeAnimation
    }

    override fun onDestroy() {
//        unregisterReceiver(endedCallkitIncomingBroadcastReceiver)
        super.onDestroy()
    }

    private fun onDeclineClick() {
        val data = intent.extras?.getBundle(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_INCOMING_DATA)
        Log.w("ACTION_CALL_DECLINE", "$data")
        val intent =
                CallsManagerBroadcastReceiver.getIntentDecline(this, data)
        sendBroadcast(intent)
    }

    private fun onAcceptClick(){
//        getIntentAccepted()
        val data = intent.extras?.getBundle(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_INCOMING_DATA)
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
}