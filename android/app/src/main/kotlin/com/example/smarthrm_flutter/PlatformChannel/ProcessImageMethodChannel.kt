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
                    val decodedImage: ByteArray = call.argument("encodeImage")
                        ?: return@setMethodCallHandler result.error(
                            "Error!",
                            "Cannot get any image from flutter",
                            ""
                        )

                    val originBitmap: Bitmap? =
                        BitmapFactory.decodeByteArray(decodedImage, 0, decodedImage.size)
                    if (originBitmap != null) {
                        return@setMethodCallHandler result.success("Success decode byte array")
                    }

                    return@setMethodCallHandler result.error(
                        "Error!",
                        "Cannot decode byte array",
                        ""
                    )
                }
                else -> result.notImplemented()
            }
        }
    }
}
