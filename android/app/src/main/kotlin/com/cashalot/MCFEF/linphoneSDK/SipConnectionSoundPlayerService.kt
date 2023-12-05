package com.cashalot.MCFEF.linphoneSDK
//
//import android.R.attr.path
//import android.content.Context
//import android.content.res.AssetFileDescriptor
//import android.content.res.AssetManager
//import android.media.AudioDeviceInfo
//import android.media.AudioManager
//import android.media.MediaPlayer
//import android.os.Build
//import android.util.Log
//
//
//class SipConnectingSoundPlayerService constructor(val context: Context) {
//
//    companion object {
//        var mediaPlayer: MediaPlayer? = null
//    }
//    val TAG: String = "[ MEDIA PLAYER ]:"
//
//    fun playAssetConnectingSound() {
//        if (mediaPlayer == null) {
//            mediaPlayer = MediaPlayer()
//        }
//
//        var afd: AssetFileDescriptor? = null
//        try {
//            afd = context.assets.openFd("connecting_sound.mp3")
//
//
//            val manager: AssetManager = context.assets
//            try {
//                val files = manager.list(path.toString())
//                if (files!!.size > 0) {
//                    Log.e(TAG, "NOT EMPTY")
//                } else {
//                    var data = context.assets.open(path.toString())
//                }
//            } catch (e: java.lang.Exception) {
//                Log.e(TAG, e.printStackTrace().toString())
//            }
//
////            assert(afd != null)
////            mediaPlayer!!.setDataSource(afd.fileDescriptor)
////
////            mediaPlayer!!.prepare()
////            mediaPlayer!!.setVolume(1f, 1f);
////            mediaPlayer!!.isLooping = true
//
//            val audioDeviceType = if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) AudioDeviceInfo.TYPE_BUILTIN_SPEAKER_SAFE else AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
//            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
//            val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
////
////            devices.forEach {
////                if (it.type == 18 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
////                    audioManager.setCommunicationDevice(it)
////                }
////            }
//            mediaPlayer!!.start()
//        } catch(error: Exception) {
//            Log.e(TAG, error.printStackTrace().toString())
//        }
//
//
//    }
//}