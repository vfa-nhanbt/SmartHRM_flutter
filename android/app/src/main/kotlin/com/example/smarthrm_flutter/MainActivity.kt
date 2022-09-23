package com.example.smarthrm_flutter

import androidx.annotation.NonNull
import com.example.smarthrm_flutter.PlatformChannel.ProcessImageMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        ProcessImageMethodChannel.instance.callMethodChannel(flutterEngine)
    }
}
