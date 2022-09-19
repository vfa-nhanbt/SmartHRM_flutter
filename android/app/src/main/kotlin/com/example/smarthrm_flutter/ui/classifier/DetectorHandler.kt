package com.example.smarthrm_flutter.ui.classifier

import asia.vitalify.hrm.ui.faces.classifier.RectModel

interface DetectorHandler {
    fun onDetectorResults(rects: List<RectModel>, emotions: Array<FloatArray>)
}