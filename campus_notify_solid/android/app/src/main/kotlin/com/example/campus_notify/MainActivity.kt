package com.example.campus_notify

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.campus_notify/badge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateBadge" -> {
                    val count = call.argument<Int>("count") ?: 0
                    updateLauncherBadge(count)
                    result.success(true)
                }
                "removeBadge" -> {
                    updateLauncherBadge(0)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun updateLauncherBadge(count: Int) {
        try {
            // 1. Xiaomi / MIUI / HyperOS Broadcast
            val xiaomiIntent = Intent("android.intent.action.APPLICATION_MESSAGE_UPDATE")
            xiaomiIntent.putExtra("android.intent.extra.update_application_component_name", "$packageName/.MainActivity")
            xiaomiIntent.putExtra("android.intent.extra.update_application_message_text", if (count > 0) count.toString() else "")
            sendBroadcast(xiaomiIntent)
        } catch (_: Exception) {}

        try {
            // 2. Samsung Broadcast
            val samsungIntent = Intent("android.intent.action.BADGE_COUNT_UPDATE")
            samsungIntent.putExtra("badge_count", count)
            samsungIntent.putExtra("badge_count_package_name", packageName)
            samsungIntent.putExtra("badge_count_class_name", "$packageName.MainActivity")
            sendBroadcast(samsungIntent)
        } catch (_: Exception) {}

        try {
            // 3. Huawei / Honor Content Provider
            val bundle = Bundle()
            bundle.putString("package", packageName)
            bundle.putString("class", "$packageName.MainActivity")
            bundle.putInt("badgenumber", count)
            contentResolver.call(Uri.parse("content://com.huawei.android.launcher.settings/badge/"), "change_badge", null, bundle)
        } catch (_: Exception) {}

        try {
            // 4. Oppo / Realme / Vivo Content Provider
            val oppoBundle = Bundle()
            oppoBundle.putInt("app_badge_count", count)
            contentResolver.call(Uri.parse("content://com.android.badge/badge"), "setAppBadgeCount", null, oppoBundle)
        } catch (_: Exception) {}
    }
}
