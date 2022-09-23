package com.example.smarthrm_flutter.PlatformChannel

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


open class ProcessImageMethodChannel {
    companion object {
        val instance: ProcessImageMethodChannel by lazy { ProcessImageMethodChannel() }
    }

    private val methodChannelName = "com.example.smarthrm_flutter/method-channel/"
    private val tag: String = "METHOD_CHANNEL"

    fun callMethodChannel(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "SendImage" -> {
                    val capturedImage: ByteArray? = call.argument("capturedImage")
                    val assetImage: ByteArray? = call.argument("assetsImage")

                    if (capturedImage != null && assetImage != null) {
                        if (byteArrayToBitmap(capturedImage) != null && byteArrayToBitmap(assetImage) != null) {
                            return@setMethodCallHandler result.success("Success decode byte array")
                        }
                    }

                    return@setMethodCallHandler result.error(
                        "Error!",
                        "Cannot get any image from flutter",
                        ""
                    )
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun byteArrayToBitmap(bytes: ByteArray): Bitmap? {
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
    }
}
