package com.shadow.blackhole

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.SharedPreferences
import android.content.ComponentName
import android.content.Context
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSession
import android.media.session.MediaSessionManager
import android.widget.RemoteViews

import android.util.Log
import androidx.core.content.ContextCompat
import androidx.core.app.ActivityCompat
import android.Manifest
import android.content.pm.PackageManager
import android.content.Intent
import io.flutter.plugin.common.MethodChannel

/**
 * Implementation of App Widget functionality.
 */
class BlackHoleMusicWidget : AppWidgetProvider() {
    // private lateinit var mediaSessionToken: MediaSession.Token
    // private lateinit var mediaController: MediaController


    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)

        Log.d("MyWidgetProvider", "Initializing MediaSession and MediaController")

        // Update widget
        updateAppWidget(context, appWidgetManager)
    }

    override fun onReceive(context: Context?, intent: android.content.Intent?) {
        super.onReceive(context, intent)

        Log.d("MyWidgetProvider", "Received intent")

        // // Handle media playback state changes
        // if (intent?.action == "android.media.session.playstatechanged") {
        //     context?.let { updateAppWidget(it, AppWidgetManager.getInstance(it)) }
        // }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager) {
        Log.d("MyWidgetProvider", "Updated intent")
        // val views = RemoteViews(context.packageName, R.layout.black_hole_music_widget).apply {
        
        // // Get the currently playing song title
        // val metadata: MediaMetadata? = mediaController.metadata
        // Log.d("MyWidgetProvider", "Currently playing: $metadata")
        // if (metadata != null) {
        //     // Get the currently playing song title
        //     val songTitle = metadata.getString(MediaMetadata.METADATA_KEY_TITLE)
        //     // Get the currently playing song artist
        //     val songArtist = metadata.getString(MediaMetadata.METADATA_KEY_ARTIST)
        //     Log.d("MyWidgetProvider", "Currently playing: $songTitle")

        //     setTextViewText(R.id.widget_title_text, songTitle ?: "Title")
        //     setTextViewText(R.id.widget_subtitle_text, songArtist ?: "Subtitle")
        // }

        // // // Open App on Widget Click
        // // val pendingIntent = HomeWidgetLaunchIntent.getActivity(
        // //         context,
        // //         MainActivity::class.java)
        // // setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        // // val skipNextIntent = HomeWidgetBackgroundIntent.getBroadcast(
        // //         context,
        // //         Uri.parse("blackhole://controls/skipNext")
        // // )
        // // setOnClickPendingIntent(R.id.widget_button_next, skipNextIntent)

        // // val skipPreviousIntent = HomeWidgetBackgroundIntent.getBroadcast(
        // //         context,
        // //         Uri.parse("blackhole://controls/skipPrevious")
        // // )
        // // setOnClickPendingIntent(R.id.widget_button_prev, skipPreviousIntent)

        // // val playPauseIntent = HomeWidgetBackgroundIntent.getBroadcast(
        // //         context,
        // //         Uri.parse("blackhole://controls/playPause")
        // // )
        // // setOnClickPendingIntent(R.id.widget_button_play_pause, playPauseIntent)

        // }

        // // appWidgetManager.updateAppWidget(appWidgetId, views)
        // val componentName = ComponentName(context, BlackHoleMusicWidget::class.java)
        // appWidgetManager.updateAppWidget(componentName, views)
    }
}

