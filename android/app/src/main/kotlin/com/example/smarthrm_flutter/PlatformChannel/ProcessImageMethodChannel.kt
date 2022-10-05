package com.example.smarthrm_flutter.PlatformChannel

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.Handler
import android.os.HandlerThread
import androidx.annotation.NonNull
import asia.vitalify.hrm.ui.faces.classifier.Classifier
import com.example.smarthrm_flutter.Utils.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.Pigeon


open class ProcessImageMethodChannel {
    companion object {
        val instance: ProcessImageMethodChannel by lazy { ProcessImageMethodChannel() }
    }

    private var imageRegisters = HashMap<FaceAspect, MutableList<Bitmap>>()
    private var isFaceDetected = false
    private lateinit var classifier: Classifier
    private var handler: Handler
    private var handlerThread: HandlerThread

    //    private var response: MutableMap<String, Any>
    var embedding: FloatArray = emptyArray<Float>().toFloatArray()
    val response = Response()

    init {
        // Initializes imageRegisters
        imageRegisters[FaceAspect.NORMAL] = mutableListOf()
        imageRegisters[FaceAspect.LEFT] = mutableListOf()
        imageRegisters[FaceAspect.RIGHT] = mutableListOf()
        imageRegisters[FaceAspect.UP] = mutableListOf()
        imageRegisters[FaceAspect.DOWN] = mutableListOf()

        handlerThread = HandlerThread("inference")
        handlerThread.start()
        handler = Handler(handlerThread.looper)
    }

    @SuppressLint("KotlinNullnessAnnotation")
    fun callPigeonMethod(@NonNull flutterEngine: FlutterEngine, classifier: Classifier) {
        this.classifier = classifier
        Pigeon.FaceImageApi.setup(flutterEngine.dartExecutor.binaryMessenger, FaceImageApi())
    }

    @Suppress("UNCHECKED_CAST")
    private class FaceImageApi : Pigeon.FaceImageApi {
        override fun processImage(faceImage: Pigeon.FaceImage): MutableMap<String, Any> {
            // Return float array if done scan face
            if (instance.embedding.isNotEmpty()) {
                instance.response.isSucceed = true
                instance.response.data["faceInfo"] = instance.embedding
                return instance.response.toMutableMap()
            }
            // else doing creating float array
            if (faceImage.encodedImage == null || faceImage.imageWidth == null || faceImage.imageHeight == null || faceImage.left == null || faceImage.top == null || faceImage.faceWidth == null || faceImage.faceHeight == null || faceImage.rotX == null || faceImage.rotY == null) {
                instance.response.errorMessage = "Didn't get enough argument from Flutter"
                return instance.response.toMutableMap()
            }

            val originBitmap: Bitmap? = faceImage.encodedImage.toBitmap(
                faceImage.imageWidth!!.toInt(),
                faceImage.imageHeight!!.toInt()
            )

            if (originBitmap == null) {
                instance.response.errorMessage = "Didn't get enough argument from Flutter"
                return instance.response.toMutableMap()
            }

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

            // Check null face bitmap
            if (faceBitmap != null) {
                val aspect = FaceUtils.getAspect(
                    faceImage.rotX!!,
                    faceImage.rotY!!
                )

                if (instance.imageRegisters[aspect]!!.size < Configuration.NUM_IMAGE_PER_ASPECT) {
                    instance.imageRegisters[aspect]!!.add(faceBitmap)

//                    // Return log aspect remain
//                    instance.response.message = "Succeed get Aspect: ${
//                        FaceUtils.getAspect(
//                            faceImage.rotX!!,
//                            faceImage.rotY!!
//                        )
//                    } - ${Configuration.NUM_IMAGE_PER_ASPECT - instance.imageRegisters[aspect]!!.size}"
                    instance.response.message =
                        "Getting aspect: $aspect... ${instance.imageRegisters[aspect]!!.size}/8"
                    (instance.response.data["faceAspect"] as MutableMap<String, Int>)["$aspect"] =
                        instance.imageRegisters[aspect]!!.size
                    return instance.response.toMutableMap()

                } else if (!instance.isFaceDetected) {
                    if (FaceUtils.isEnoughFrame(instance.imageRegisters)) {
                        instance.isFaceDetected = true

                        // Create embedding in background
                        instance.runInBackground {
                            instance.embedding =
                                instance.generateEmbedded(FaceUtils.getAllBitmap(instance.imageRegisters))
                        }
                    }
                }
            }
            return instance.response.toMutableMap()
        }

    }

    // Generate embedded from face bitmap
    private fun generateEmbedded(face: Bitmap): FloatArray {
        return classifier.run(face)
    }

    // Generate embedded from list of face bitmaps
    private fun generateEmbedded(faces: List<Bitmap>): FloatArray {
        val vectors = mutableListOf<FloatArray>()
        for (face in faces) {
            val vector = generateEmbedded(face)
            vectors.add(vector)
        }
        return MatrixTools.sumAndNormalizeVector(vectors)
    }

    @Synchronized
    open fun runInBackground(runnable: () -> Unit) {
        handler.post(runnable)
    }
}

