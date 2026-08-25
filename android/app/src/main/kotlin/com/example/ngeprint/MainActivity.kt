package com.example.ngeprint

import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Parcelable
import android.provider.OpenableColumns
import android.util.Log
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private var methodChannel: MethodChannel? = null
    private var initialDelivered = false
    private val pendingMedia = mutableListOf<Map<String, String>>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                .apply {
                    setMethodCallHandler { call, result ->
                        when (call.method) {
                            METHOD_GET_INITIAL_MEDIA ->
                                result.success(drainSharedMedia())
                            else -> result.notImplemented()
                        }
                    }
                }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val media = extractSharedMedia(intent)
        if (media.isEmpty()) return
        if (initialDelivered) {
            methodChannel?.invokeMethod(METHOD_ON_MEDIA_RECEIVED, media)
        } else {
            synchronized(pendingMedia) { pendingMedia += media }
        }
    }

    private fun drainSharedMedia(): List<Map<String, String>> {
        synchronized(pendingMedia) {
            val media = mutableListOf<Map<String, String>>()
            if (!initialDelivered) {
                initialDelivered = true
                media += extractSharedMedia(intent)
            }
            media += pendingMedia.toList()
            pendingMedia.clear()
            return media
        }
    }

    private fun extractSharedMedia(intent: Intent?): List<Map<String, String>> {
        if (intent == null) return emptyList()
        val action = intent.action ?: return emptyList()
        if (action != Intent.ACTION_SEND && action != Intent.ACTION_SEND_MULTIPLE) {
            return emptyList()
        }
        val media = mutableListOf<Map<String, String>>()
        extractStreamUris(intent).forEachIndexed { index, uri ->
            cacheSharedFile(uri, index)?.let { media += it }
        }
        return media
    }

    private fun extractStreamUris(intent: Intent): List<Uri> {
        return when (intent.action) {
            Intent.ACTION_SEND ->
                listOfNotNull(intent.parcelableExtra<Uri>(Intent.EXTRA_STREAM))
            Intent.ACTION_SEND_MULTIPLE ->
                intent.parcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
                    .orEmpty()
                    .filterNotNull()
            else -> emptyList()
        }
    }

    private fun cacheSharedFile(uri: Uri, index: Int): Map<String, String>? {
        return try {
            val resolver = contentResolver
            val displayName =
                queryDisplayName(resolver, uri)
                    ?: "shared_${System.currentTimeMillis()}_$index"
            val safeName = displayName
                .replace(Regex("[^A-Za-z0-9._ ()-]"), "_")
                .ifBlank { "shared_$index" }
            val sharedDir = File(cacheDir, SHARED_DIR_NAME).apply { mkdirs() }
            val target = uniqueTarget(File(sharedDir, safeName))
            resolver.openInputStream(uri)?.use { input ->
                target.outputStream().use { output -> input.copyTo(output) }
            } ?: return null
            mapOf(
                KEY_PATH to target.absolutePath,
                KEY_MIME_TYPE to (
                    resolver.getType(uri) ?: guessMimeType(safeName)
                ),
            )
        } catch (error: Exception) {
            Log.w(TAG, "Gagal menyalin berkas hasil share", error)
            null
        }
    }

    private fun uniqueTarget(target: File): File {
        if (!target.exists()) return target
        val baseName = target.nameWithoutExtension
        val extension = target.extension
        var attempt = 1
        var candidate = File(target.parentFile, "$baseName ($attempt).$extension")
        while (candidate.exists()) {
            attempt += 1
            candidate = File(target.parentFile, "$baseName ($attempt).$extension")
        }
        return candidate
    }

    private fun queryDisplayName(
        resolver: ContentResolver,
        uri: Uri,
    ): String? {
        return try {
            resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
                ?.use { cursor ->
                    if (cursor.moveToFirst()) cursor.getString(0) else null
                }
        } catch (error: Exception) {
            Log.w(TAG, "Gagal membaca nama berkas", error)
            null
        }
    }

    private fun guessMimeType(fileName: String): String {
        val extension = fileName.substringAfterLast('.', "").lowercase()
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
            ?: "application/octet-stream"
    }

    private inline fun <reified T : Parcelable> Intent.parcelableExtra(
        name: String,
    ): T? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            getParcelableExtra(name, T::class.java)
        } else {
            @Suppress("DEPRECATION")
            getParcelableExtra(name) as? T
        }
    }

    private inline fun <reified T : Parcelable> Intent.parcelableArrayListExtra(
        name: String,
    ): ArrayList<T?>? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            getParcelableArrayListExtra(name, T::class.java)
        } else {
            @Suppress("DEPRECATION")
            getParcelableArrayListExtra(name)
        }
    }

    companion object {
        private const val TAG = "NgeprintShareIntent"
        private const val CHANNEL_NAME = "app.ngeprint/share_intent"
        private const val METHOD_GET_INITIAL_MEDIA = "getInitialSharedMedia"
        private const val METHOD_ON_MEDIA_RECEIVED = "onSharedMediaReceived"
        private const val SHARED_DIR_NAME = "shared_imports"
        private const val KEY_PATH = "path"
        private const val KEY_MIME_TYPE = "mimeType"
    }
}
