package com.example.smarthrm_flutter.Utils

import android.content.Context
import android.util.Log
import java.io.BufferedReader
import java.io.FileInputStream
import java.io.IOException
import java.io.InputStreamReader
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel
import java.nio.charset.StandardCharsets

object ModelLoader {

    @Throws(IOException::class)
    fun loadMappedFile(context: Context, rawId: Int): MappedByteBuffer {
        Log.d("loadMappedFile: ", rawId.toString())
        val fileDescriptor = context.resources.openRawResourceFd(rawId)
        val mappedByteBuffer: MappedByteBuffer
        try {
            val inputStream = FileInputStream(fileDescriptor!!.fileDescriptor)
            mappedByteBuffer = try {
                val fileChannel = inputStream.channel
                val startOffset = fileDescriptor.startOffset
                val declaredLength = fileDescriptor.declaredLength
                fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
            } catch (throwable: Throwable) {
                try {
                    inputStream.close()
                } catch (_throwable: Throwable) {
                    throwable.addSuppressed(_throwable)
                }
                throw throwable
            }

            inputStream.close()

        } catch (throwable: Throwable) {
            if (fileDescriptor != null) {
                try {
                    fileDescriptor.close()
                } catch (_throwable: Throwable) {
                    throwable.addSuppressed(_throwable)
                }
            }
            throw throwable
        }

        fileDescriptor.close()

        return mappedByteBuffer
    }

    fun loadRawFile(context: Context, rawId: Int): List<String> {
        val results: MutableList<String> = ArrayList()
        var reader: BufferedReader? = null
        try {
            reader = BufferedReader(
                InputStreamReader(
                    context.resources.openRawResource(rawId),
                    StandardCharsets.UTF_8
                )
            )

            // do reading, usually loop until end of file reading
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                results.add(line!!)
            }
        } catch (e: IOException) {
            e.message?.let { Log.e("ModelLoader", it) }
        } finally {
            reader?.close()
        }
        return results
    }
}