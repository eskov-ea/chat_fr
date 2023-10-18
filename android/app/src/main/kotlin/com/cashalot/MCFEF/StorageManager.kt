package com.cashalot.MCFEF
import android.content.Context
import com.cashalot.MCFEF.linphoneSDK.CoreContext
import io.flutter.Log

class StorageManager constructor(var context: Context) {

    fun readData(): String? {
        val sharedPreference =  context.getSharedPreferences(CoreContext.PREFERENCE_FILENAME,Context.MODE_PRIVATE)
        val contacts = sharedPreference.getString("contacts", null)
        Log.i("SIP_CONTACTS readData", contacts.toString())
        return contacts
    }

    fun writeData(data: String) {
        val sharedPreference =  context.getSharedPreferences(CoreContext.PREFERENCE_FILENAME,Context.MODE_PRIVATE)
        val editor = sharedPreference.edit()
        editor.putString("contacts",data)
        editor.apply()
    }
}