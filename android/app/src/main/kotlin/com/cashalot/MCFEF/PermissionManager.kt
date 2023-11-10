package com.cashalot.MCFEF

import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat


class PermissionManager(val activity: Activity, val list: List<String>, val code: Int) {

    var result: Int = 0;

    fun checkPermissions() {
        result = isPermissionsGranted()
        if(result != PackageManager.PERMISSION_GRANTED) {
            showAlert()
        }
    }

    private fun isPermissionsGranted(): Int {
        // PERMISSION_GRANTED : Constant Value: 0
        // PERMISSION_DENIED : Constant Value: -1
        var counter = 0;
        for (permission in list) {
            if (permission == Manifest.permission.READ_EXTERNAL_STORAGE) {
                if (Build.VERSION.SDK_INT < 29) {
                    counter += ContextCompat.checkSelfPermission(activity, permission)
                }
            } else if (permission == Manifest.permission.READ_MEDIA_IMAGES) {
                if (Build.VERSION.SDK_INT > 32) {
                    counter += ContextCompat.checkSelfPermission(activity, permission)
                }
            } else {
                counter += ContextCompat.checkSelfPermission(activity, permission)
            }
        }
        return counter
    }

    private fun deniedPermission(): String {
        for (permission in list) {
            if (ContextCompat.checkSelfPermission(activity, permission)
                == PackageManager.PERMISSION_DENIED) return permission
        }
        return ""
    }

    private fun showAlert() {
        val builder = AlertDialog.Builder(activity, R.style.PermissionAlertDialogStyle)
        builder.setTitle("Подтвердить разрешение")
        builder.setMessage("Приложению для корректной работы необходим доступ к камере, микрофону, галлереи и возможность отправки уведомлений")
        builder.setPositiveButton(" Разрешить ", { dialog, which -> requestPermissions() })
        builder.setNeutralButton(" Отменить ", null)
        val dialog = builder.create()
        dialog.show()
    }

    private fun showExplanationAlert() {
        val builder = AlertDialog.Builder(activity, R.style.PermissionAlertDialogStyle)
        builder.setTitle("Ограничение доступа")
        builder.setMessage("Приложению для корректной работы необходим доступ к камере, микрофону, галлереи и возможность отправки уведомлений. Вы в любой момент можете изменить разрешения в настройках приложения")
        val dialog = builder.create()
        dialog.show()
    }

    private fun requestPermissions() {
        val permission = deniedPermission()
        if (ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)) {
            showExplanationAlert()
            ActivityCompat.requestPermissions(activity, list.toTypedArray(), code)
        } else {
            ActivityCompat.requestPermissions(activity, list.toTypedArray(), code)
        }
    }

    fun processPermissionsResult(requestCode: Int, permissions: Array<String>,
                                 grantResults: IntArray): Boolean {
        var result = 0
        if (grantResults.isNotEmpty()) {
            for (item in grantResults) {
                result += item
            }
        }
        if (result == PackageManager.PERMISSION_GRANTED) return true
        return false
    }

}