package com.example.smarthrm_flutter

import Classifier
import androidx.annotation.NonNull
import asia.vitalify.hrm.ui.faces.classifier.DeviceType
import com.example.smarthrm_flutter.PlatformChannel.ProcessImageMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var classifier: Classifier
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        classifier = Classifier.Builder(this).apply {
            setDevice(DeviceType.CPU)
            setNumberThreads(4)
        }.build()

        ProcessImageMethodChannel.instance.callMethodChannel(flutterEngine, classifier)
    }
}
