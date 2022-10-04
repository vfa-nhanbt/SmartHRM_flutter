package asia.vitalify.hrm.ui.faces.classifier

import android.content.Context
import android.graphics.Bitmap
import com.example.smarthrm_flutter.R
import com.example.smarthrm_flutter.Utils.ModelLoader
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.gpu.CompatibilityList
import org.tensorflow.lite.gpu.GpuDelegate
import org.tensorflow.lite.nnapi.NnApiDelegate
import org.tensorflow.lite.support.common.TensorOperator
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.image.ops.ResizeOp
import java.nio.MappedByteBuffer
import kotlin.math.exp


/** A classifier specialized to label images using TensorFlow Lite. */
class Classifier(context: Context, deviceType: DeviceType, numThreads: Int) {

    /** The loaded TensorFlow Lite model. */
    private var recogModel: MappedByteBuffer? = null
    private var dModel: MappedByteBuffer? = null
    private var eModel: MappedByteBuffer? = null

    /** Image size along the x axis. */
    private var sizeX = 0
    private var dSizeX = 0
    private var eSizeX = 0

    /** Image size along the y axis. */
    private var sizeY = 0
    private var dSizeY = 0
    private var eSizeY = 0

    /** Optional GPU delegate for acceleration. */
    private var gpuDelegate: GpuDelegate? = null

    /** Optional NNAPI delegate for acceleration. */
    private var nnApiDelegate: NnApiDelegate? = null

    /**  An instance of the driver class to run model inference with Tensorflow Lite. */
    private var interpreter: Interpreter? = null
    private var dInterpreter: Interpreter? = null
    private var eInterpreter: Interpreter? = null

    /** Input image TensorBuffer. */
    private var inputImageBuffer: TensorImage? = null
    private var dInputImageBuffer: TensorImage? = null
    private var eInputImageBuffer: TensorImage? = null

    /** Contains the location of detected boxes
     * outputBoxes: array of shape [batch_size, NUM_DETECTIONS,4] */
    private lateinit var outputBoxes: Array<Array<FloatArray>>

    /** Contains the classes of 5 landmarks
     * outputLandmarks: array of shape [batch_size, NUM_DETECTIONS, 10] */
    private lateinit var outputLandmarks: Array<Array<FloatArray>>

    /** Contains the scores of score for containing face
     * outputScores: array of shape [batch_size, NUM_DETECTIONS, 2] */
    private lateinit var outputScores: Array<Array<FloatArray>>

    private lateinit var anchors: Array<FloatArray>

    companion object {
        private const val iouScore = 0.2f // iou threshold
        private const val confScore = 0.90f // confident threshold

        /** Float MobileNet requires additional normalization of the used input. */
        private const val IMAGE_MEAN = 114.495f
        private const val IMAGE_STD = 57.63f
    }

    init {
        recogModel = ModelLoader.loadMappedFile(context, R.raw.recognition)
        dModel = ModelLoader.loadMappedFile(context, R.raw.detector)
        eModel = ModelLoader.loadMappedFile(context, R.raw.emotion)

        val tfliteOptions = Interpreter.Options()
        val dTfliteOptions = Interpreter.Options()
        val eTfliteOptions = Interpreter.Options()
        val compatList = CompatibilityList()

        when (deviceType) {

            DeviceType.NNAPI -> {
                nnApiDelegate = NnApiDelegate()
                tfliteOptions.addDelegate(nnApiDelegate)
                dTfliteOptions.addDelegate(nnApiDelegate)
                eTfliteOptions.addDelegate(nnApiDelegate)
            }

            DeviceType.GPU -> {
                val delegateOptions = compatList.bestOptionsForThisDevice
                gpuDelegate = GpuDelegate(delegateOptions)
                tfliteOptions.addDelegate(gpuDelegate)
                dTfliteOptions.addDelegate(gpuDelegate)
                eTfliteOptions.addDelegate(gpuDelegate)
            }

            DeviceType.CPU -> {}
        }

        tfliteOptions.numThreads = numThreads
        dTfliteOptions.numThreads = numThreads
        eTfliteOptions.numThreads = numThreads

        interpreter = Interpreter(recogModel!!, tfliteOptions)
        dInterpreter = Interpreter(dModel!!, dTfliteOptions)
        eInterpreter = Interpreter(eModel!!, eTfliteOptions)

        val shape = interpreter!!.getInputTensor(0).shape() // {1, 640, 640, 3}
        sizeY = shape[1]
        sizeX = shape[2]
        inputImageBuffer = TensorImage(interpreter!!.getInputTensor(0).dataType())

        val dShape = dInterpreter!!.getInputTensor(0).shape() // {1, 640, 640, 3}
        dSizeY = dShape[1]
        dSizeX = dShape[2]
        dInputImageBuffer = TensorImage(dInterpreter!!.getInputTensor(0).dataType())

        val eShape = eInterpreter!!.getInputTensor(0).shape() // {1, 640, 640, 3}
        eSizeY = eShape[1]
        eSizeX = eShape[2]
        eInputImageBuffer = TensorImage(eInterpreter!!.getInputTensor(0).dataType())
    }

    /** Loads input image, and applies preprocessing. */
    private fun loadImage(
        tensorImage: TensorImage?,
        bitmap: Bitmap,
        sizeX: Int,
        sizeY: Int
    ): TensorImage? {
        // Loads bitmap into a TensorImage
        tensorImage!!.load(bitmap)

        // Creates processor for the TensorImage
        val imageProcessor = ImageProcessor.Builder()
            .add(ResizeOp(sizeX, sizeY, ResizeOp.ResizeMethod.NEAREST_NEIGHBOR))
            .build()
        return imageProcessor.process(tensorImage)
    }

    private fun loadImage(
        tensorImage: TensorImage?,
        bitmap: Bitmap,
        sizeX: Int,
        sizeY: Int,
        tensorOperator: TensorOperator
    ): TensorImage? {
        // Loads bitmap into a TensorImage
        tensorImage!!.load(bitmap)

        // Creates processor for the TensorImage
        val imageProcessor = ImageProcessor.Builder()
            .add(ResizeOp(sizeX, sizeY, ResizeOp.ResizeMethod.NEAREST_NEIGHBOR))
            .add(tensorOperator)
            .build()
        return imageProcessor.process(tensorImage)
    }

    fun run(bitmap: Bitmap?): FloatArray {
        val processBitmap = Bitmap.createScaledBitmap(bitmap!!, 112, 112, true)
        inputImageBuffer = loadImage(inputImageBuffer, processBitmap, sizeX, sizeY)
        val outputFloat = Array(1) {
            FloatArray(128)
        }
        interpreter?.run(inputImageBuffer?.buffer, outputFloat)
        return outputFloat[0]
    }

//    private fun makeAnchors(context: Context) {
//        anchors = Array(16800) { FloatArray(4) }
//        val result = ModelLoader.loadRawFile(context, R.raw.anchors)
//        for (i in result.indices) {
//            val split = result[i].split(" ").toTypedArray()
//            for (j in split.indices) {
//                anchors[i][j] = split[j].toFloat()
//            }
//        }
//    }

    private fun decodeBox(anchors: Array<FloatArray>, boxes: Array<FloatArray>) {
        for (i in 0..16799) {
            // xy
            val x = anchors[i][0] + boxes[i][0] * anchors[i][2]
            val y = anchors[i][1] + boxes[i][1] * anchors[i][3]

            // wh
            val w = anchors[i][2] * exp(boxes[i][2].toDouble()).toFloat()
            val h = anchors[i][3] * exp(boxes[i][3].toDouble()).toFloat()

            // trans
            boxes[i][0] = x - 0.5f * w
            boxes[i][1] = y - 0.5f * h
            boxes[i][2] = x + 0.5f * w
            boxes[i][3] = y + 0.5f * h
        }
    }

    /** Closes the interpreter and model to release resources. */
    fun close() {
        if (interpreter != null) {
            interpreter!!.close()
            interpreter = null
        }

        if (dInterpreter != null) {
            dInterpreter!!.close()
            dInterpreter = null
        }

        if (eInterpreter != null) {
            eInterpreter!!.close()
            eInterpreter = null
        }

        if (gpuDelegate != null) {
            gpuDelegate!!.close()
            gpuDelegate = null
        }

        if (nnApiDelegate != null) {
            nnApiDelegate!!.close()
            nnApiDelegate = null
        }

        recogModel = null
        dModel = null
        eModel = null
    }

    class Builder(
        private var context: Context,
        private var deviceType: DeviceType = DeviceType.CPU,
        private var numThreads: Int = 4
    ) {
        /**
         * Creates a classifier builder with the provided device.
         *
         * @param deviceType The device to use for classification.
         * @return A classifier builder with the desired device.
         */
        fun setDevice(deviceType: DeviceType) = apply { this.deviceType = deviceType }

        /**
         * Creates a classifier builder with the provided numThreads.
         *
         * @param numThreads The number of threads to use for classification
         * @return A classifier builder with the desired numThreads.
         */
        fun setNumberThreads(numThreads: Int) = apply { this.numThreads = numThreads }

        fun build() = Classifier(context, deviceType, numThreads)
    }
}