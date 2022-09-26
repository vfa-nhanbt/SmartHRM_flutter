package com.example.smarthrm_flutter.PlatformChannel

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import androidx.annotation.NonNull
import com.example.smarthrm_flutter.Utils.FaceUtils
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
                    // Get arguments from Flutter
                    val capturedImage: ByteArray? = call.argument("capturedImage")
                    val left: Int? = call.argument("left")
                    val top: Int? = call.argument("top")
                    val width: Int? = call.argument("width")
                    val height: Int? = call.argument("height")
                    val rotX: Double? = call.argument("rotX")
                    val rotY: Double? = call.argument("rotY")

                    // Create bitmap from capturedImage
                    val originBitmap: Bitmap = byteArrayToBitmap(capturedImage)
                        ?: return@setMethodCallHandler result.error(
                            "NullException!",
                            "Cannot decode image from Flutter side",
                            ""
                        )

                    // Create new bitmap depend on decoded one
                    val matrix = Matrix()
                    matrix.preScale(-1f, 1f)
                    matrix.postRotate(90f)

                    val bitmap = Bitmap.createBitmap(
                        originBitmap,
                        0,
                        0,
                        originBitmap.width,
                        originBitmap.height,
                        matrix,
                        true
                    )

                    // Create face bitmap
                    val faceBitmap: Bitmap? = try {
                        Bitmap.createBitmap(bitmap, left!!, top!!, width!!, height!!)
                    } catch (ex: Exception) {
                        null
                    }

                    if (faceBitmap != null) {
                        return@setMethodCallHandler result.success(
                            "Succeed create face bitmap from Flutter bitmap with Aspect: ${
                                FaceUtils.getAspect(
                                    rotX!!,
                                    rotY!!
                                )
                            }"
                        )
                    }

                    return@setMethodCallHandler result.error(
                        "Error!",
                        "Cannot decode image from Flutter side",
                        ""
                    )
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun byteArrayToBitmap(bytes: ByteArray?): Bitmap? {
        if (bytes == null)
            return null
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
    }
}
