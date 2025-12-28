package com.example.digital_family_system

import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.digital_family_system/open_file"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openFile") {
                val filePath = call.argument<String>("filePath")
                val mimeType = call.argument<String>("mimeType") ?: "application/pdf"
                
                if (filePath != null) {
                    try {
                        openFile(filePath, mimeType)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to open file: ${e.message}", null)
                    }
                } else {
                    result.error("ERROR", "File path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun openFile(filePath: String, mimeType: String) {
        val file = File(filePath)
        if (!file.exists()) {
            throw Exception("File does not exist: $filePath")
        }

        var uri: Uri? = null
        var useFileProvider = false

        // Try FileProvider first for Android 7.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            try {
                uri = FileProvider.getUriForFile(
                    this,
                    "${applicationContext.packageName}.fileprovider",
                    file
                )
                useFileProvider = true
            } catch (e: Exception) {
                // FileProvider failed, will try file:// URI
                useFileProvider = false
            }
        }

        // If FileProvider failed or Android < 7.0, use file:// URI
        if (uri == null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                // Android 7.0+ doesn't allow file:// URIs, but we'll try anyway
                // Some devices might still work
                uri = Uri.parse("file://$filePath")
            } else {
                // Android < 7.0 can use file:// URI directly
                uri = Uri.fromFile(file)
            }
        }

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeType)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            if (useFileProvider) {
                // Grant read permission for FileProvider URI
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            } else {
                // For file:// URIs, try to grant permissions
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
            }
        }

        // Try to resolve and start the activity
        try {
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
            } else {
                // If no app found, try with a more generic intent
                val genericIntent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "*/*")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                if (genericIntent.resolveActivity(packageManager) != null) {
                    startActivity(genericIntent)
                } else {
                    throw Exception("No app found to open PDF file. Please install a PDF viewer.")
                }
            }
        } catch (e: SecurityException) {
            // Handle permission issues
            throw Exception("Permission denied: ${e.message}")
        } catch (e: Exception) {
            throw Exception("Failed to open file: ${e.message}")
        }
    }
}
