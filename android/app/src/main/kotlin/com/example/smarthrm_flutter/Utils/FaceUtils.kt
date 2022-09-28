package com.example.smarthrm_flutter.Utils

import android.graphics.Bitmap
import android.graphics.Rect
import kotlin.math.abs

object FaceUtils {
    fun getFaceBitmap(bitmap: Bitmap, bounds: Rect): Bitmap? {
        return try {
            val left = bounds.left
            val top = bounds.top
            val width = bounds.width()
            val height = bounds.height()
            Bitmap.createBitmap(bitmap, left, top, width, height)
        } catch (ex: Exception) {
            null
        }
    }

    fun getAspect(rotX: Double, rotY: Double): FaceAspect {
        return if (abs(rotX) < Configuration.DELTA_NORMAL_ASPECT && abs(rotY) < Configuration.DELTA_NORMAL_ASPECT) {
            FaceAspect.NORMAL
        } else if (abs(rotX) > abs(rotY)) {
            if (rotX > 0) {
                FaceAspect.UP
            } else {
                FaceAspect.DOWN
            }
        } else {
            if (rotY > 0) {
                FaceAspect.RIGHT
            } else {
                FaceAspect.LEFT
            }
        }
    }

    fun isEnoughFrame(imageRegisters: HashMap<FaceAspect, MutableList<Bitmap>>): Boolean {
        var totalFrame = 0
        for (i in FaceAspect.values()) {
            totalFrame += imageRegisters[i]!!.size
        }
        return totalFrame == Configuration.MAX_FRAME_REGISTER
    }

    fun getAllBitmap(imageRegisters: HashMap<FaceAspect, MutableList<Bitmap>>): List<Bitmap> {
        val result = mutableListOf<Bitmap>()
        for (aspect in FaceAspect.values()) {
            result.addAll(imageRegisters[aspect]!!)
        }
        return result
    }
}