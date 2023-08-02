package com.example.MCFEF
import android.content.Context
import com.example.MCFEF.linphoneSDK.CoreContext
import java.io.BufferedReader
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.InputStreamReader
import io.flutter.Log
import java.io.File

class StorageManager constructor(var context: Context) {

//    private val filename: String = "mcfef_sip_contacts.txt"
//    private val file: File = File(context.filesDir.absolutePath, filename)
//    var fIn: FileOutputStream = FileOutputStream(file)
//    var fOut: FileInputStream = FileInputStream(file)

//    fun readData(): String? {
//        val bufferedReader: BufferedReader = file.bufferedReader()
//        return bufferedReader.use { it.readText() }
//    }
//
//    fun writeData(data: ByteArray) {
//        fIn.use {
//            it.write(data)
//        }
//    }

    fun readData(): String? {
        val sharedPreference =  context.getSharedPreferences(CoreContext.PREFERENCE_FILENAME,Context.MODE_PRIVATE)
        val contacts = sharedPreference.getString("contacts", null)
        return contacts
    }

    fun writeData(data: String) {
        val sharedPreference =  context.getSharedPreferences(CoreContext.PREFERENCE_FILENAME,Context.MODE_PRIVATE)
        val editor = sharedPreference.edit()
        editor.putString("contacts",data)
        editor.apply()
    }
}