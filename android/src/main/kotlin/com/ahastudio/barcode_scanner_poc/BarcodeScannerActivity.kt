package com.ahastudio.barcode_scanner_poc

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import java.util.concurrent.Executors


import android.util.Log
import android.widget.Toast
import androidx.annotation.OptIn
import androidx.camera.view.PreviewView

class BarcodeScannerActivity : AppCompatActivity() {
    private lateinit var previewView: PreviewView
    private lateinit var barcodeScanner: BarcodeScanner
    private val cameraExecutor = Executors.newSingleThreadExecutor()
    private val requestCameraPermission = 10

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_barcode_scanner)
        previewView = findViewById(R.id.previewView)
        barcodeScanner = BarcodeScanning.getClient()

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            startCamera()
        } else {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), requestCameraPermission)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == requestCameraPermission && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            startCamera()
        } else {
            Toast.makeText(this, "Camera permissions delegated", Toast.LENGTH_SHORT).show()
            finish()
        }
    }

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()
            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }
            val imageAnalysis = ImageAnalysis.Builder().build().also {
                it.setAnalyzer(cameraExecutor) { imageProxy ->
                    processImageProxy(imageProxy)
                }
            }
            try {
                cameraProvider.unbindAll()
                val camera = cameraProvider.bindToLifecycle(
                    this,
                    CameraSelector.DEFAULT_BACK_CAMERA,
                    preview,
                    imageAnalysis
                )

                // --- Control de enfoque automático en el centro ---
                val cameraControl = camera.cameraControl
                val factory = SurfaceOrientedMeteringPointFactory(
                    previewView.width.toFloat(),
                    previewView.height.toFloat()
                )
                val point = factory.createPoint(
                    previewView.width / 2f,
                    previewView.height / 2f
                )
                val action = FocusMeteringAction.Builder(point).build()
                cameraControl.startFocusAndMetering(action)

                // --- Control de zoom (ejemplo: zoom al 50%) ---
                cameraControl.setLinearZoom(0.5f) // 0.0f = sin zoom, 1.0f = máximo zoom

                // --- Control de exposición (ejemplo: compensación +1 si está soportado) ---
                val cameraInfo = camera.cameraInfo
                val exposureRange = cameraInfo.exposureState.exposureCompensationRange
                if (exposureRange.contains(1)) {
                    cameraControl.setExposureCompensationIndex(1)
                }

            } catch (exc: Exception) {
                Log.e("BarcodeScanner", "Error to start the camera", exc)
            }
        }, ContextCompat.getMainExecutor(this))
    }

    @OptIn(ExperimentalGetImage::class)
    private fun processImageProxy(imageProxy: ImageProxy) {
        val mediaImage = imageProxy.image
        if (mediaImage != null) {
            val image = InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)
            barcodeScanner.process(image)
                .addOnSuccessListener { barcodes ->
                    for (barcode in barcodes) {
                        val value = barcode.rawValue
                        val resultIntent = Intent()
                        resultIntent.putExtra("barcode_value", value)
                        setResult(Activity.RESULT_OK, resultIntent)
                        finish()
                        break
                    }
                }
                .addOnFailureListener {
                    Log.e("BarcodeScanner", "Error to process the code bar", it)
                }
                .addOnCompleteListener {
                    imageProxy.close()
                }
        } else {
            imageProxy.close()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
    }
}
