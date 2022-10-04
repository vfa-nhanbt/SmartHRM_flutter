package com.example.smarthrm_flutter

import android.annotation.SuppressLint
import androidx.annotation.NonNull
import asia.vitalify.hrm.ui.faces.classifier.Classifier
import asia.vitalify.hrm.ui.faces.classifier.DeviceType
import com.example.smarthrm_flutter.PlatformChannel.ProcessImageMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var classifier: Classifier

    @SuppressLint("KotlinNullnessAnnotation")
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        classifier = Classifier.Builder(this).apply {
            setDevice(DeviceType.CPU)
            setNumberThreads(4)
        }.build()

//        ProcessImageMethodChannel.instance.callMethodChannel(flutterEngine)
        ProcessImageMethodChannel.instance.callPigeonMethod(flutterEngine, classifier)
    }
}
