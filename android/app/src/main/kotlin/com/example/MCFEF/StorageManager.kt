package com.example.MCFEF

import android.content.Context
import java.io.BufferedReader
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.InputStreamReader

class StorageManager(context: Context) {

    private val filename: String = "mcfef_sip_contacts"
    var fIn: FileOutputStream = context.openFileOutput(filename, Context.MODE_PRIVATE)
    var fOut: FileInputStream = context.openFileInput(filename)

    fun readData(): String? {
        var inputStreamReader: InputStreamReader = InputStreamReader(fOut)
        val bufferedReader: BufferedReader = BufferedReader(inputStreamReader)
        val stringBuilder: StringBuilder = StringBuilder()
        var text: String? = null

        while ({
                    text = bufferedReader.readLine();
                    text
        }() != null) {
            stringBuilder.append(text)
        }
        return text
    }

    fun writeData(data: ByteArray) {
        fIn.write(data)
    }
}