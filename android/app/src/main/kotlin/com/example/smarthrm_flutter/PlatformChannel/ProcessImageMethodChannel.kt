package com.example.smarthrm_flutter.PlatformChannel

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.Matrix
import androidx.annotation.NonNull
import com.example.smarthrm_flutter.Utils.FaceUtils
import com.example.smarthrm_flutter.Utils.toBitmap
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.Pigeon


open class ProcessImageMethodChannel {
    companion object {
        val instance: ProcessImageMethodChannel by lazy { ProcessImageMethodChannel() }
    }

    private val methodChannelName = "com.example.smarthrm_flutter/method-channel/"
    private val tag: String = "METHOD_CHANNEL"

    @SuppressLint("KotlinNullnessAnnotation")
    fun callPigeonMethod(@NonNull flutterEngine: FlutterEngine) {
        Pigeon.FaceImageApi.setup(flutterEngine.dartExecutor.binaryMessenger, FaceImageApi())
    }

    private class FaceImageApi : Pigeon.FaceImageApi {
        override fun processImage(faceImage: Pigeon.FaceImage): String {
            if (faceImage.encodedImage == null || faceImage.imageWidth == null || faceImage.imageHeight == null || faceImage.left == null || faceImage.top == null || faceImage.faceWidth == null || faceImage.faceHeight == null || faceImage.rotX == null || faceImage.rotY == null) {
                return "Didn't get enough argument from Flutter"
            }

            val originBitmap: Bitmap = faceImage.encodedImage.toBitmap(
                faceImage.imageWidth!!.toInt(),
                faceImage.imageHeight!!.toInt()
            ) ?: return "NullException! - Cannot decode image from Flutter side"
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
                Bitmap.createBitmap(
                    bitmap,
                    faceImage.left!!.toInt(),
                    faceImage.top!!.toInt(),
                    faceImage.faceWidth!!.toInt(),
                    faceImage.faceHeight!!.toInt(),
                )
            } catch (ex: Exception) {
                null
            }

            if (faceBitmap != null) {
                return "Succeed create face bitmap from Flutter bitmap with Aspect: ${
                    FaceUtils.getAspect(
                        faceImage.rotX!!,
                        faceImage.rotY!!
                    )
                }"

            }

            return ""
        }
    }
}
