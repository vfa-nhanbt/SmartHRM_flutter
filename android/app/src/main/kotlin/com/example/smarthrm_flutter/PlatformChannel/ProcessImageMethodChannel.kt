package com.example.smarthrm_flutter.PlatformChannel


import Classifier
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class ProcessImageMethodChannel {
    companion object {
        val instance: ProcessImageMethodChannel by lazy { ProcessImageMethodChannel() }
    }

    private val methodChannelName = "com.example.smarthrm_flutter/method-channel/"
    private lateinit var classifier: Classifier


    fun callMethodChannel(@NonNull flutterEngine: FlutterEngine, classifier: Classifier) {

        this.classifier = classifier

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "processImageFromCamera" -> {
                    // Get cameraImage from Flutter-side, Check null
                    val cameraImage: ByteArray? = call.argument("imageByteArray")
                    if (cameraImage == null || cameraImage.isEmpty()) {
                        result.error(
                            "NullPointerException",
                            "Type cannot be empty",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    // Create bitmap from byteArray --> Getting null here
                    val originBitmap: Bitmap =
                        BitmapFactory.decodeByteArray(cameraImage, 0, cameraImage.size)

                    Log.d("NATIVE_LOG_BITMAP_VALUE", "Bitmap: $originBitmap")

                    return@setMethodCallHandler result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
