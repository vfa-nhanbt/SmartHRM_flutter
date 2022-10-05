package com.example.smarthrm_flutter.PlatformChannel

data class Response(
    var isSucceed: Boolean = false,
    var message: String = "",
    var errorMessage: String? = null,
    var data: MutableMap<String, Any?> = mutableMapOf(
        "faceInfo" to emptyArray<Float>().toFloatArray(),
        "faceAspect" to mutableMapOf(
            "UP" to 0,
            "DOWN" to 0,
            "LEFT" to 0,
            "RIGHT" to 0,
            "NORMAL" to 0,
        ),
    ),
)

