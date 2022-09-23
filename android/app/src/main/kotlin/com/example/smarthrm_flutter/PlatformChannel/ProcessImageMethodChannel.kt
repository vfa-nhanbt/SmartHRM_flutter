package com.example.smarthrm_flutter.PlatformChannel

import android.graphics.Bitmap
import androidx.annotation.NonNull
import com.example.smarthrm_flutter.Utils.toBitmap
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
                    val decodedImage: List<ByteArray>? = call.argument("encodeImage")
                    val width: Int? = call.argument("width")
                    val height: Int? = call.argument("height")
                    if (decodedImage == null || width == null || height == null) {
                        return@setMethodCallHandler result.error(
                            "Error!",
                            "Cannot get any image from flutter",
                            ""
                        )
                    }

                    val originBitmap: Bitmap? = decodedImage.toBitmap(width, height)
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
