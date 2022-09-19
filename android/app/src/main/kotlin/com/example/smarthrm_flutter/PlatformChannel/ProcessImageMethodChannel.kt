package com.example.smarthrm_flutter.PlatformChannel

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.os.Handler
import android.os.HandlerThread
import android.util.Base64
import android.util.Log
import androidx.annotation.NonNull
import asia.vitalify.hrm.ui.faces.classifier.Classifier
import com.example.smarthrm_flutter.Utils.Configuration
import com.example.smarthrm_flutter.Utils.FaceAspect
import com.example.smarthrm_flutter.Utils.FaceUtils
import com.example.smarthrm_flutter.Utils.MatrixTools
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


open class ProcessImageMethodChannel {
    companion object {
        val instance: ProcessImageMethodChannel by lazy { ProcessImageMethodChannel() }
    }

    private val tag: String = "METHOD_CHANNEL"
    private val methodChannelName = "com.example.smarthrm_flutter/method-channel/"
    private lateinit var classifier: Classifier
    private var handler: Handler
    private var handlerThread: HandlerThread

    private var imageRegisters = HashMap<FaceAspect, MutableList<Bitmap>>()
    private var isFaceDetected = false

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

    fun callMethodChannel(@NonNull flutterEngine: FlutterEngine, classifier: Classifier) {

        this.classifier = classifier

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "processCameraImage" -> {

                    // get arguments passing from FLutter
                    val imageString: String? = call.argument("image")
                    val decodedString: ByteArray = Base64.decode(imageString, Base64.DEFAULT)
                    val originBitmap: Bitmap =
                        BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)

                    // Create bitmap from Flutter image source
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

                    val image = InputImage.fromBitmap(bitmap, 0)

                    // High-accuracy landmark detection and face classification
                    val options = FaceDetectorOptions.Builder()
                        .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
                        .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_NONE)
                        .build()

                    // Get an instance of FaceDetector
                    val detector = FaceDetection.getClient(options)

                    // Process the image
                    detector.process(image)
                        .addOnSuccessListener { faces ->
                            // Task completed successfully
                            if (faces.isNotEmpty()) {
                                val faceDetected = faces[0]
                                val rotX = faceDetected.headEulerAngleX
                                val rotY = faceDetected.headEulerAngleY
                                val bounds = faceDetected.boundingBox

                                val faceBitmap = FaceUtils.getFaceBitmap(bitmap, bounds)

                                if (faceBitmap != null) {
                                    val aspect = FaceUtils.getAspect(rotX, rotY)
                                    if (imageRegisters[aspect]!!.size < Configuration.NUM_IMAGE_PER_ASPECT) {
                                        imageRegisters[aspect]!!.add(faceBitmap)
                                    }
                                    if (!isFaceDetected) {
//                                        if (FaceUtils.isEnoughFrame(imageRegisters)) {
                                        if (true) {
                                            isFaceDetected = true

                                            // Generate embedded
                                            runInBackground {
                                                val embedding =
                                                    generateEmbedded(
                                                        FaceUtils.getAllBitmap(imageRegisters)
                                                    )
                                                // Register face
                                                Log.d(tag, embedding.toString())
                                            }
                                        }
                                    }
                                }
                            } else {
                                // Clear face bounds
                                Log.d(tag, "Clear face bounds")
                            }
                            // Process nex image
                            Log.d(tag, "Process next image")
                            handlerThread.quitSafely()
                        }
                        .addOnFailureListener {
                            Log.d(tag, "Process next image from Failure listener")
                        }
                }
                "SendFaces" -> {
                    val face: Face? = call.argument("face")
                    if (face != null) {
                        Log.d("callMethodChannel: ", face.toString())
                    } else {
                        
                    }
                }
                else -> result.notImplemented()
            }
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
