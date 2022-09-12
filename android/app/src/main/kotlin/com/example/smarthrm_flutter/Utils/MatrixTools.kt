package com.example.smarthrm_flutter.Utils

import kotlin.math.sqrt

object MatrixTools {
    fun multiply(firstMatrix: FloatArray, secondMatrix: List<FloatArray>): FloatArray {
        val result = FloatArray(secondMatrix.size) { 0f }
        secondMatrix.forEachIndexed { index, floats ->
            var sum = 0f
            for (i in firstMatrix.indices) {
                sum += floats[i] * firstMatrix[i]
            }
            result[index] = sum
        }
        return result

    }

    fun sumVectors(vectors: List<FloatArray>): FloatArray {
        val result = FloatArray(128) { .0f }
        val sizeOfOneVector = vectors[0].size
        for (i in 0 until sizeOfOneVector) {
            var sum = 0f
            for (vector in vectors) {
                sum += vector[i]
            }
            result[i] = sum / vectors.size
        }
        return result
    }

    fun normalizeVectors(vector: FloatArray): FloatArray {
        var sum = 0f
        for (i in vector) {
            sum += i * i
        }
        return vector.map { it / sqrt(sum) }.toFloatArray()
    }

    fun sumAndNormalizeVector(vectors: List<FloatArray>): FloatArray {
        val sumVector = sumVectors(vectors)
        return normalizeVectors(sumVector)
    }
}