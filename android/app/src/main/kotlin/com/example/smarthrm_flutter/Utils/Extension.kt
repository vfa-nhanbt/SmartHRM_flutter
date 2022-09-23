package com.example.smarthrm_flutter.Utils

import android.graphics.*
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

fun List<ByteArray>?.toBitmap(width: Int, height: Int): Bitmap? {
    val yBuffer: ByteBuffer = ByteBuffer.wrap(this!![0])
    val uBuffer: ByteBuffer = ByteBuffer.wrap(this[1])
    val vBuffer: ByteBuffer = ByteBuffer.wrap(this[2])

    val ySize = yBuffer.remaining()
    val uSize = uBuffer.remaining()
    val vSize = vBuffer.remaining()

    val nv21 = ByteArray(ySize + uSize + vSize)

    // U and V are swapped
    yBuffer.get(nv21, 0, ySize)
    vBuffer.get(nv21, ySize, vSize)
    uBuffer.get(nv21, ySize + vSize, uSize)

    val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
    val out = ByteArrayOutputStream()
    yuvImage.compressToJpeg(Rect(0, 0, yuvImage.width, yuvImage.height), 100, out)
    val imageBytes = out.toByteArray()
    return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
}