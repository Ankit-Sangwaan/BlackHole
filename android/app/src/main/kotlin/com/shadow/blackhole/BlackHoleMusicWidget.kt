package com.shadow.blackhole

import MainActivity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import android.content.BroadcastReceiver
import android.content.Intent
import android.content.IntentFilter
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import java.util.*

/**
 * Implementation of App Widget functionality.
 */
class AudioListenerActivity : AppCompatActivity() {
    private val audioReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent?.getByteArrayExtra("audio_data")?.let { audioData ->
                // Process the received audio data
                // For example, you could visualize or analyze the audio data

                // Get the associated image data
                currentImageData = intent.getByteArrayExtra("image_data")

                // Update the widget with the new image data
                updateAppWidget()
            }
        }
    }
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, widgetData: SharedPreferences) {
    val views = RemoteViews(context.packageName, R.layout.black_hole_music_widget).apply {
    // Open App on Widget Click
    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java)
    setOnClickPendingIntent(R.id.widget_container, pendingIntent)

    setTextViewText(R.id.widget_title_text, widgetData.getString("title", null)
            ?: "Title")
    setTextViewText(R.id.widget_subtitle_text, widgetData.getString("message", null)
            ?: "Subtitle")

    val skipNextIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("blackhole://controls/skipNext")
    )
    setOnClickPendingIntent(R.id.widget_button_next, skipNextIntent)

    val skipPreviousIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("blackhole://controls/skipPrevious")
    )
    setOnClickPendingIntent(R.id.widget_button_prev, skipPreviousIntent)

    val playPauseIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("blackhole://controls/playPause")
    )
    setOnClickPendingIntent(R.id.widget_button_play_pause, playPauseIntent)

    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}