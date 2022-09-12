import android.content.Context
import android.graphics.Bitmap
import asia.vitalify.hrm.ui.faces.classifier.DeviceType
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.common.TensorOperator
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.image.ops.ResizeOp

class Classifier(context: Context, deviceType: DeviceType, numThreads: Int) {
    private var inputImageBuffer: TensorImage? = null

    /** Image size along the x axis. */
    private var sizeX = 0
    private var dSizeX = 0
    private var eSizeX = 0

    /** Image size along the y axis. */
    private var sizeY = 0
    private var dSizeY = 0
    private var eSizeY = 0

    /**  An instance of the driver class to run model inference with Tensorflow Lite. */
    private var interpreter: Interpreter? = null

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

    fun close() {
        if (interpreter != null) {
            interpreter!!.close()
            interpreter = null
        }
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